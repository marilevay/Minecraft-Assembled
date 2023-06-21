#entrada: tamanho da matriz quadrada de pixels
n = int(input())
#entrada: linha única com valores dos pixels separados por vírgulas
#(assim como gerado por pixel2dotdata.py e provavelmente o conversor de oac)
array = [int(i) for i in input().split(',')]
matrix = []
for i in range(n):
    row = [array[i] for i in range(i*n, n*(i+1))]
    matrix.append(row)
nm = [[0 for i in range(n)] for i in range(n)]
#saída: três linhas com as imagens rotacionadas 90 graus para a direita em sequência
for out in range(3):
    print("\n")
    for i in range(n):
        for j in range(n):
            nm[i][j] = matrix[n-1-j][i]
            print(nm[i][j], end=',')
    for i in range(n):
        for j in range(n):
            matrix[i][j] = nm[i][j]
    
