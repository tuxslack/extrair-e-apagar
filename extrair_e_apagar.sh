#!/usr/bin/env bash
#
# Por: Jonas Santana
# Colaboração: Fernando Souza https://github.com/tuxslack / https://www.youtube.com/@fernandosuporte
# Data: 31/10/2025
# Licença: MIT
#
# Extrai arquivos compactados para uma pasta com o nome do arquivo
# e remove o original após extração, se desejado pelo usuário.

# ----------------------------------------------------------------------------------------
# Pré-requisitos
if ! command -v yad &>/dev/null; then
    notify-send "❌ Dependência ausente" "'yad' não está instalado. Instale com: sudo apt install -y yad"
    exit 1
fi

if ! command -v notify-send &>/dev/null; then
    echo "❌ O 'notify-send' não está instalado. Instale com: sudo apt install -y libnotify-bin"
    exit 1
fi

# ----------------------------------------------------------------------------------------
# Pergunta única para todos os arquivos
yad --center \
    --title="Remover arquivos originais?" \
    --question \
    --text="Deseja remover os arquivos originais após a extração?\n\n(Será removido automaticamente em 6 segundos se não houver resposta)" \
    --buttons-layout=center \
    --button="Sim:0" --button="Não:1" \
    --timeout=6 \
    --timeout-indicator=bottom \
    --width="500" --height="150" \
    2>/dev/null

resposta=$?

# Converter resposta em SIM/NAO
if [ "$resposta" -eq 1 ]; then
    REMOVER="NAO"
else
    REMOVER="SIM"
fi

# ----------------------------------------------------------------------------------------
# Loop de extração
for arquivo in "$@"; do
    if [ -f "$arquivo" ]; then
        pasta_destino="$(dirname "$arquivo")"
        nome_base="$(basename "$arquivo")"

        # Remove extensões conhecidas
        nome_sem_extensao="$nome_base"
        for ext in ".tar.zst" ".tar.bz2" ".tar.gz" ".tar.xz" ".tbz2" ".tgz" ".tar" ".zip" ".rar" ".7z" ".bz2" ".gz" ".xz" ".zst" ".lz4" ".lzma" ".Z" ".cab" ".iso"; do
            nome_sem_extensao="${nome_sem_extensao%$ext}"
        done

        pasta_extraida="$pasta_destino/$nome_sem_extensao"
        mkdir -p "$pasta_extraida"
        cd "$pasta_destino" || exit 1

        echo "----------------------------------------"
        echo "Extraindo: $arquivo"
        echo "Destino: $pasta_extraida"
        echo "----------------------------------------"

        notify-send "Extração iniciada" "$arquivo → $pasta_extraida"

        case "$arquivo" in
            *.tar.zst)  tar --zstd -xvf "$arquivo" -C "$pasta_extraida" ;;
            *.tar.bz2)  tar xvjf "$arquivo" -C "$pasta_extraida" ;;
            *.tar.gz)   tar xvzf "$arquivo" -C "$pasta_extraida" ;;
            *.tar.xz)   tar xvJf "$arquivo" -C "$pasta_extraida" ;;
            *.tbz2)     tar xvjf "$arquivo" -C "$pasta_extraida" ;;
            *.tgz)      tar xvzf "$arquivo" -C "$pasta_extraida" ;;
            *.tar)      tar xvf "$arquivo" -C "$pasta_extraida" ;;
            *.zip)      unzip -o "$arquivo" -d "$pasta_extraida" ;;
            *.rar)      unrar x -ad "$arquivo" "$pasta_extraida" ;;
            *.7z)       7z x "$arquivo" -o"$pasta_extraida" ;;
            *.bz2)      cp "$arquivo" "$pasta_extraida" && bunzip2 "$pasta_extraida/$nome_base" ;;
            *.gz)       cp "$arquivo" "$pasta_extraida" && gunzip "$pasta_extraida/$nome_base" ;;
            *.xz)       cp "$arquivo" "$pasta_extraida" && unxz "$pasta_extraida/$nome_base" ;;
            *.zst)      cp "$arquivo" "$pasta_extraida" && unzstd "$pasta_extraida/$nome_base" ;;
            *.lz4)      cp "$arquivo" "$pasta_extraida" && lz4 -d "$pasta_extraida/$nome_base" "${pasta_extraida}/${nome_sem_extensao}" ;;
            *.lzma)     cp "$arquivo" "$pasta_extraida" && unlzma "$pasta_extraida/$nome_base" ;;
            *.Z)        cp "$arquivo" "$pasta_extraida" && uncompress "$pasta_extraida/$nome_base" ;;
            *.cab)      cabextract -d "$pasta_extraida" "$arquivo" ;;
            *.iso)      7z x "$arquivo" -o"$pasta_extraida" ;;
            *)          echo "⚠️ Tipo de arquivo não suportado: $arquivo"
                        notify-send "Aviso" "Tipo de arquivo não suportado: $arquivo" ;;
        esac

        # Remove arquivo original se opção SIM
        if [ "$REMOVER" = "SIM" ]; then
            rm -f "$arquivo"
            echo "✅ Extraído e removido: $arquivo"
            notify-send "Arquivo removido" "$arquivo"
        else
            echo "🟡 Arquivo mantido: $arquivo"
            notify-send "Arquivo mantido" "$arquivo"
        fi
    else
        echo "Arquivo não encontrado: $arquivo"
        notify-send "Aviso" "Arquivo não encontrado: $arquivo"
    fi
done

notify-send "Processo concluído" "Todos os arquivos foram processados..."
exit 0

