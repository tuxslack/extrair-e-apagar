#!/usr/bin/env bash
#
# Por: Jonas Santana
# Colaboração: Fernando Souza https://github.com/tuxslack / https://www.youtube.com/@fernandosuporte
# Data: 31/10/2025
# Licença:  MIT
#
# Extrai arquivos compactados para uma pasta com o nome do arquivo
# e remove o original após extração bem-sucedida.
#
# https://plus.diolinux.com.br/t/extrair-e-apagar-extraia-arquivos-compactados-no-xfce/78268
#
# ChangeLog
# =========
# Fernando Souza - 31/10/2025
# • Adicionadas notificações gráficas (notify-send)
# • Suporte a novos formatos (.xz, .zst, .tar.zst, .lzma, .cab, .iso)
# • Removida confirmação com YAD (por decisão do autor original)
# ----------------------------------------------------------------------------------------

# Verifica se o notify-send está instalado
if ! command -v notify-send &> /dev/null; then
    echo "❌ O notify-send não está instalado. Instale-o antes de continuar."
    echo "No Debian/Ubuntu: sudo apt update && sudo apt install -y libnotify-bin"
    sleep 5
fi

# ----------------------------------------------------------------------------------------

for arquivo in "$@"; do
    if [ -f "$arquivo" ]; then
        pasta_destino="$(dirname "$arquivo")"
        nome_base="$(basename "$arquivo")"

        # Remove extensões conhecidas (compostas primeiro)
        nome_sem_extensao="$nome_base"
        nome_sem_extensao="${nome_sem_extensao%.tar.zst}"
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
        nome_sem_extensao="${nome_sem_extensao%.xz}"
        nome_sem_extensao="${nome_sem_extensao%.zst}"
        nome_sem_extensao="${nome_sem_extensao%.lz4}"
        nome_sem_extensao="${nome_sem_extensao%.lzma}"
        nome_sem_extensao="${nome_sem_extensao%.Z}"
        nome_sem_extensao="${nome_sem_extensao%.cab}"
        nome_sem_extensao="${nome_sem_extensao%.iso}"

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
            *)          echo -e "\n⚠️ Tipo de arquivo não suportado: $arquivo \n"
                        notify-send "Aviso" "Tipo de arquivo não suportado: $arquivo" ;;
        esac

        if [ $? -eq 0 ]; then
            rm -f "$arquivo"
            echo "✅ Extraído e removido: $arquivo"
            notify-send "Extraído e removido" "$arquivo"
        else
            echo "⚠️ Erro ao extrair: $arquivo"
            notify-send "Erro" "Falha ao extrair: $arquivo"
        fi
    else
        echo "Arquivo não encontrado: $arquivo"
        notify-send "Aviso" "Arquivo não encontrado: $arquivo"
    fi
done

echo -e "\n✔️ Processo concluído.\n"
notify-send "Processo concluído" "Todos os arquivos foram processados..."
exit 0
