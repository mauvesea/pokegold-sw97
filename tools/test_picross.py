#!/usr/bin/env python3
"""Headless Picross regression checks (requires PyBoy).

Run after make: python tools/test_picross.py [pokegold.sgb ...]
ROM overrides are confined to the emulator. No game saves are read or written.
"""
import argparse
from pathlib import Path
import tempfile

from pyboy import PyBoy


def symbols(path):
    result = {}
    for line in path.read_text().splitlines():
        if not line or line.startswith(';') or ':' not in line.split()[0]:
            continue
        address, name = line.split()
        bank, offset = address.split(':')
        result[name] = (int(bank, 16), int(offset, 16))
    return result


def bitmap(tiles):
    rows = []
    for y in range(16):
        row = []
        for x in range(16):
            offset = ((y // 8) * 2 + x // 8) * 16 + (y % 8) * 2
            row.append(int(bool((tiles[offset] & tiles[offset + 1]) & (0x80 >> (x % 8)))))
        rows += row
    return rows


def run(rom, cgb):
    syms = symbols(rom.with_suffix('.sym'))
    def addr(name):
        return syms[name][1]

    # Verify linker allocation and its disjointness from live animation/video data.
    start, end = addr('wPicrossRAM'), addr('wPicrossRAMEnd')
    assert start == addr('wOverworldMapBlocks')
    assert end <= addr('wOverworldMapBlocksEnd')
    assert addr('wSpriteAnimDataEnd') <= start
    assert end <= addr('wBGMapBuffer')
    assert addr('sPicrossMapBackup') + 1300 <= addr('sPartyMail')

    patterns = [
        Path('gfx/icons/diglett.2bpp').read_bytes()[:64],
        Path('gfx/icons/ghost.2bpp').read_bytes()[:64],
        Path('gfx/icons/unown.2bpp').read_bytes()[:64],
        Path('gfx/icons/snorlax.2bpp').read_bytes()[:64],
        Path('gfx/tilesets/pokecenter.2bpp').read_bytes()[0x200:0x220]
        + Path('gfx/tilesets/pokecenter.2bpp').read_bytes()[0x300:0x320],
        Path('gfx/sprites/poliwrath.2bpp').read_bytes()[:64],
    ]
    with tempfile.TemporaryDirectory(prefix='picross-test-') as directory:
        copy = Path(directory) / 'game.gb'
        copy.write_bytes(rom.read_bytes())
        for stage in range(6):
            p = PyBoy(str(copy), window='null', sound_emulated=False, cgb=cgb)
            p.set_emulation_speed(0)
            p.tick(600)
            armed = True
            def enter(_):
                nonlocal armed
                if not armed:
                    return
                armed = False
                bank, entry = syms['PicrossMinigame']
                palette = addr('PicrossSetupPalettes')
                p.memory[0x2000] = bank
                p.memory[addr('hROMBank')] = bank
                for name, value in [('hInMenu', 1), ('hMapAnims', 0), ('hVBlank', 0),
                                    ('hOAMUpdate', 0), ('wScriptVar', stage), ('wJoypadDisable', 0)]:
                    p.memory[addr(name)] = value
                p.memory[addr('hBGMapAddress'):addr('hBGMapAddress') + 2] = [0, 0x9c]
                # Unused rst $30 slot: palette setup, minigame, return loop.
                p.memory[0, 0x30:0x38] = [0xcd, palette & 255, palette >> 8,
                                         0xcd, entry & 255, entry >> 8, 0x18, 0xfe]
                p.memory[start - 1] = 0xa5
                p.memory[end:addr('wOverworldMapBlocksEnd')] = [0x5a] * (addr('wOverworldMapBlocksEnd') - end)
                p.register_file.PC = 0x30
            p.hook_register(*syms['DelayFrame'], enter, None)
            p.tick(1)
            p.hook_deregister(*syms['DelayFrame'])
            assert not armed
            p.tick(240)
            def read(name):
                return p.memory[addr(name)]
            def press(key, frames=2, rest=20):
                p.button_press(key)
                p.tick(frames)
                p.button_release(key)
                p.tick(rest)
            def cursor():
                a = addr('wPicrossCursorSpritePointer')
                return p.memory[a] | (p.memory[a + 1] << 8)
            expected = bitmap(patterns[stage])
            assert read('wPicrossErrorCheck') == 0, (stage, 'clue overflow')
            assert list(p.memory[addr('wPicrossBitmap'):addr('wPicrossBitmap') + 256]) == expected
            assert read('wJumptableIndex') == 1
            if stage == 0:
                press('a'); assert read('wPicrossMarkedCells') == 1
                press('a'); assert read('wPicrossMarkedCells') == 0
                press('b'); assert read('wPicrossMarkedCells') == 2
                press('b'); assert read('wPicrossMarkedCells') == 0
                press('left'); press('up')
                assert tuple(p.memory[cursor() + 4:cursor() + 6]) == (64, 64)
                press('right', 160); press('down', 160)
                assert tuple(p.memory[cursor() + 4:cursor() + 6]) == (154, 154)
                press('start'); assert read('wJumptableIndex') == 1

                # Hold A while moving: the prototype keeps the original paint
                # choice instead of toggling each newly visited square.
                p.memory[cursor() + 4:cursor() + 6] = [64, 64]
                press('a')
                p.button_press('a')
                p.button_press('right')
                p.tick(48)
                p.button_release('a')
                p.button_release('right')
                p.tick(20)
                assert all(p.memory[addr('wPicrossMarkedCells') + i] == 1 for i in range(5))
                # Clear the painted strip through the normal drawing path.
                for i in range(16):
                    if p.memory[addr('wPicrossMarkedCells') + i]:
                        p.memory[cursor() + 4:cursor() + 6] = [64 + 6 * i, 64]
                        press('a')
                        assert p.memory[addr('wPicrossMarkedCells') + i] == 0

            # Cover every filled cell and all 16 packed-grid drawing routines.
            # Position the cursor directly to avoid coupling coverage to travel time.
            for cell, filled in enumerate(expected):
                if not filled:
                    continue
                p.memory[cursor() + 4:cursor() + 6] = [64 + 6 * (cell % 16), 64 + 6 * (cell // 16)]
                press('a')
                assert p.memory[addr('wPicrossMarkedCells') + cell] == 1, (stage, cell)
            assert read('wJumptableIndex') == 2, (stage, 'completion')
            assert p.memory[cursor()] == 0, 'completed cursor must be deallocated'
            press('start')
            assert read('wJumptableIndex') == 0x82
            assert p.memory[start - 1] == 0xa5
            assert all(v == 0x5a for v in p.memory[end:addr('wOverworldMapBlocksEnd')])
            p.stop(save=False)
            print(f'{rom.name} {"CGB" if cgb else "DMG"}: stage {stage + 1} passed')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('roms', nargs='*', type=Path, default=[Path('pokegold.sgb')])
    args = parser.parse_args()
    for rom in args.roms:
        for cgb in (False, True):
            run(rom, cgb)
