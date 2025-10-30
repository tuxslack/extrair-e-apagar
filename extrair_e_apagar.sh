#!/bin/bash
# Extrai arquivos compactados para uma pasta com o nome do arquivo
# e remove o original após extração bem-sucedida.

for arquivo in "$@"; do
    if [ -f "$arquivo" ]; then
        pasta_destino="$(dirname "$arquivo")"
        nome_base="$(basename "$arquivo")"

        # Remove todas as extensões conhecidas (inclusive compostas)
        nome_sem_extensao="$nome_base"
        nome_sem_extensao="${nome_sem_extensao%.tar.bz2}"
        nome_sem_extensao="${nome_sem_extensao%.tar.gz}"
        nome_sem_extensao="${nome_sem_extensao%.tar.xz}"
        nome_sem_extensao="${nome_sem_extensao%.tbz2}"
        nome_sem_extensao="${nome_sem_extensao%.tgz}"
        nome_sem_extensao="${nome_sem_extensao%.tar}"
        nome_sem_extensao="${nome_sem_extensao%.zip}"
        nome_sem_extensao="${nome_sem_extensao%.rar}"
        nome_sem_extensao="${nome_sem_extensao%.7z}"
        nome_sem_extensao="${nome_sem_extensao%.bz2}"
        nome_sem_extensao="${nome_sem_extensao%.gz}"
        nome_sem_extensao="${nome_sem_extensao%.lz4}"
        nome_sem_extensao="${nome_sem_extensao%.Z}"

        pasta_extraida="$pasta_destino/$nome_sem_extensao"

        mkdir -p "$pasta_extraida"
        cd "$pasta_destino" || exit 1

        echo "----------------------------------------"
        echo "Extraindo: $arquivo"
        echo "Destino: $pasta_extraida"
        echo "----------------------------------------"

        case "$arquivo" in
            *.tar.bz2)   tar xvjf "$arquivo" -C "$pasta_extraida" ;;
            *.tar.gz)    tar xvzf "$arquivo" -C "$pasta_extraida" ;;
            *.tar.xz)    tar xvJf "$arquivo" -C "$pasta_extraida" ;;
            *.tbz2)      tar xvjf "$arquivo" -C "$pasta_extraida" ;;
            *.tgz)       tar xvzf "$arquivo" -C "$pasta_extraida" ;;
            *.tar)       tar xvf "$arquivo" -C "$pasta_extraida" ;;
            *.zip)       unzip -o "$arquivo" -d "$pasta_extraida" ;;
            *.rar)       unrar x -ad "$arquivo" "$pasta_extraida" ;;
            *.7z)        7z x "$arquivo" -o"$pasta_extraida" ;;
            *.bz2)       cp "$arquivo" "$pasta_extraida" && bunzip2 "$pasta_extraida/$nome_base" ;;
            *.gz)        cp "$arquivo" "$pasta_extraida" && gunzip "$pasta_extraida/$nome_base" ;;
            *.lz4)       cp "$arquivo" "$pasta_extraida" && lz4 -d "$pasta_extraida/$nome_base" "${pasta_extraida}/${nome_sem_extensao}" ;;
            *.Z)         cp "$arquivo" "$pasta_extraida" && uncompress "$pasta_extraida/$nome_base" ;;
            *)           echo "⚠️ Tipo de arquivo não suportado: $arquivo" ;;
        esac

        if [ $? -eq 0 ]; then
            rm -f "$arquivo"
            echo "✅ Extraído e removido: $arquivo"
        else
            echo "⚠️ Erro ao extrair: $arquivo"
        fi
    else
        echo "Arquivo não encontrado: $arquivo"
    fi
done

echo ""
echo "✔️ Processo concluído. Pode fechar este terminal."
read -p "Pressione Enter para sair..."

