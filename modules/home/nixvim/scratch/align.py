# -*- coding: utf-8 -*-

lines_content = [
    "            󱄅   M A N X   S Y S T E M",
    "               N E O V I M   E N G I N E",
    "",
    "   ███╗   ███╗  █████╗  ███╗   ██╗ ██╗  ██╗",
    "   ████╗ ████║ ██╔══██╗ ████╗  ██║ ╚██╗██╔╝",
    "   ██╔████╔██║ ███████║ ██╔██╗ ██║  ╚███╔╝",
    "   ██║╚██╔╝██║ ██╔══██║ ██║╚██╗██║  ██╔██╗",
    "   ██║ ╚═╝ ██║ ██║  ██║ ██║ ╚████║ ██╔╝ ██╗",
    "   ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝  ╚═╝",
    "",
    "           P R E C I S I O N   L O G I C"
]

def visual_len(s):
    nerd_fonts = {"󱄅", "", ""}
    return sum(2 if char in nerd_fonts else 1 for char in s)

print("          header = [")
print('            " "')
print('            "  ▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜"')

for content in lines_content:
    vlen = visual_len(content)
    needed = 50 - vlen
    if needed > 0:
        padded = content + " " * needed
    else:
        padded = content
    print(f'            "  ▌{padded}▐"')

print('            "  ▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟"')
print('            " "')
print('          ];')
