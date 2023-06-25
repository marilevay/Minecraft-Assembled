# Código a ser executado no Google Colab para ter maior flexibilidade no upload das imagens


from google.colab import drive
from PIL import Image

# Conectar ao seu drive
drive.mount('/content/drive')

# Caminho até o arquivo png (faça o upload do arquivo direto na aba "Arquivos" do colab, clique nos três pontos à direita e escolha a opção de "Copiar Caminho")
png_file_path = '/content/porta_madeira.png'

# Carregue o arquivo png
image = Image.open(png_file_path)

# Converter imagem para RGB se ela tiver o canal alpha
if image.mode == 'RGBA':
    image = image.convert('RGB')

# Redimensionar a imagem caso necessário
width, height = 12, 12
image = image.resize((width, height), Image.ANTIALIAS)

# Coletar dados dos pixels
pixels = list(image.getdata())
print(pixels)

# Definir o caminho do arquivo de saída, juntamente com seu nome
output_file_path = '/content/porta_madeira.data'

# Escreva os dados dos pixels para o arquivo de saída
with open(output_file_path, 'w') as file:
    # Escrever dimensões
    file.write(f"porta_madeira: .word {image.width}, {image.height}\n")
    file.write(f".byte ")
    # Escrever valores dos pixels
    for y in range(12):
        for x in range(12):
            pixel = pixels[y * 12 + x]
            file.write(f"{pixel[0]},{pixel[1]},{pixel[2]},")
        file.write('\n')

# Adicionar uma ultima nova linha ao final do arquivo
with open(output_file_path, 'a') as file:
    file.write('\n')
