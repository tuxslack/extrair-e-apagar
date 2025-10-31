# extrair-e-apagar

Script simples para extrair arquivos compactados dentro de uma pasta com o mesmo nome do arquivo e, após a extração bem-sucedida, **apagar o arquivo original compactado**.  
Ideal para quem quer evitar duplicar espaço entre o `.zip` e os arquivos extraídos.

Compatível com:
zip, rar, 7z, tar, tar.gz, tar.xz, tar.bz2, tgz, tbz2, bz2, gz, Z, lz4, lzma, xz, zst, tar.zst, cab, iso.

---

## 🧰 Instalação

1. Baixe o script ou clone o repositório:
   ```bash
   git clone git@github.com:jonas854/extrair-e-apagar.git
   cd extrair-e-apagar
   ```

2. Dê permissão de execução:

   ```bash
   chmod +x extrair_e_apagar.sh
   ```

3. Mova o script para um diretório da sua preferencia:
    Ex: Documentos

   ```bash
   sudo mv extrair_e_apagar.sh ~/Documentos/extrair_e_apagar
   ```

## 🧩 Integração com o Thunar (XFCE)
Você pode integrar o script diretamente ao menu de contexto do Thunar (clicar com o botão direito > "Extrair e apagar").

1️⃣ Abra as ações personalizadas do Thunar

No Thunar, clique em Editar → Configurar ações personalizadas...

Clique em + para adicionar uma nova ação.

2️⃣ Preencha os campos:

Nome: Extrair e apagar

Descrição: Extrai o arquivo em uma pasta e apaga o original

Comando:

   ```bash
   ~/Documentos/extrair_e_apagar %F
   ```

3️⃣ Defina os tipos de arquivo

Na aba Condições de aparência, marque:

“Arquivos”

E adicione os padrões:
   ```bash
    *.zip;*.rar;*.7z;*.tar;*.tar.gz;*.tar.xz;*.tar.bz2;*.tgz;*.tbz2;*.bz2;*.gz;*.Z;*.lz4;*.lzma;*.xz;*.zst;*.tar.zst;*.cab;*.iso
   ```

Clique em OK para salvar.

## 🖼️ Exemplos de configuração no Thunar

Abaixo estão exemplos de como configurar as ações personalizadas no Thunar para usar o script:

![Configuração 1](thunar1.png)
![Configuração 2](thunar2.png)


4️⃣ Teste

Agora, no Thunar:

Clique com o botão direito em um arquivo .zip (ou outro compatível)

Escolha Ações personalizadas → Extrair e apagar

⏱️ Confirmação com YAD e timeout

O script utiliza YAD para perguntar uma única vez se os arquivos originais devem ser apagados após a extração.

Se o usuário clicar Sim, os arquivos são removidos após a extração.

Se clicar Não, os arquivos permanecem no disco.

Caso não haja resposta em 6 segundos (timeout), o script considera Sim como padrão e remove os arquivos automaticamente.

Essa abordagem foi implementada por dois motivos:

Segurança e prevenção de erros: evita exclusão acidental de arquivos importantes, seguindo boas práticas de design de interação (Jakob Nielsen).

Eficiência de espaço: ao remover imediatamente os arquivos após extrair, evita ocupar espaço desnecessário com arquivos duplicados, especialmente útil ao lidar com múltiplos arquivos grandes.

💡 A ideia do timeout com YAD foi do colaborador Fernando Souza, permitindo que o script seja seguro e prático sem bloquear o fluxo de extração.


💬 Créditos

Criado por Jonas S.
Colaboração: Fernando Souza (https://github.com/tuxslack)
