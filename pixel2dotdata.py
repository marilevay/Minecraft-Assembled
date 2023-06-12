#! python3 - pixel2dotdata.py
# Converter strings de pixel em arquivo .data RARS.16.1 RISCV-32

conversion = {'r': int('0b00000111', 2),
              'b': int('0b11000000', 2),
              'y': int('0b11111000', 2),
              'g': int('0b10111010', 2),
              'o': int('0b10010111', 2),
              'p': int('0b11000101', 2),
              'w': int('0b11111111', 2),
              'z': int('0b00000000', 2),
              'v': int('0b11000111', 2),
              'k': int('0b11011111', 2),
              'c': int('0b11010010', 2),
              'f': int('0b00111000', 2),
              'n': int('0b01010111', 2)
              }

colors = {'r': 'red', 'b': 'blue', 'y': 'yellow',
              'g': 'green', 'o': 'orange', 'p': 'purple',
              'w': 'white', 'z': 'black', 'v': 'void',
              'k': 'pink', 'c': 'cyan', 'f': 'forest',
              'n': 'brown'}
print()
for color in colors:
    print(color + ':', colors[color])
print()

question = True
while question:
    try:
        h, w = [int(i) for i in input("Insira a altura e a largura em pixels, separadas por espaço: ").split()]
        if h > 0 and w > 0:
            question = False
    except:
        question = True
    if question:
        print("Por favor, insira dois números positivos.")

ans = []
for i in range(h):
    pixelstring = input(f"Insira as cores dos {w} pixels, em letras minúsculas, sem espaçamento: ")
    while len(pixelstring) != w:
        print('Erro na quantidade de pixels.')
        pixelstring = input(f"Insira as cores dos {w} pixels, em letras minúsculas: ")
    for pixel in pixelstring:
        ans.append(conversion[pixel])
print()
print('file: .word', str(w) + ', ' + str(h))
print('.byte')
for i in range(len(ans)):
    data= ans[i]
    if i == len(ans)-1:
        print(data)
        continue
    print(str(data) + ',', end=' ')
print()
