#!/usr/bin/env bash
#
# Por: Jonas Santana
# Colaboração: Fernando Souza https://github.com/tuxslack / https://www.youtube.com/@fernandosuporte
# Data: 31/10/2025
# Licença:  MIT

# Extrai arquivos compactados para uma pasta com o nome do arquivo
# e opcionalmente remove o original após extração bem-sucedida.

# https://plus.diolinux.com.br/t/extrair-e-apagar-extraia-arquivos-compactados-no-xfce/78268

# Fork: https://github.com/jonas854/extrair-e-apagar


# ChangeLog
# =========

# Fernando Souza - 31/10/2025

# Confirmação via yad antes de remover o arquivo original.

# Extensões adicionais (.xz, .zst, .tar.zst, .lzma, .cab, .iso).

# Adicionada notificações gráficas usando o notify-send.


clear


# ----------------------------------------------------------------------------------------

notifica_final(){

echo -e "\n✔️ Processo concluído. \n"

sleep 1

notify-send "Processo concluído" "Todos os arquivos foram processados..."

}


# Problema com notify-send no OpenBox

# GDBus.Error:org.freedesktop.DBus.Error.NoReply: Message recipient disconnected from message bus without replying

# Significa que o daemon de notificações (notification daemon) não está rodando ou travou.


# Para Openbox

# Verifica se o Openbox está em execução

if pgrep -x openbox > /dev/null; then

    # Mata qualquer instância antiga do dunst

    pkill dunst 2>/dev/null

    # Inicia o dunst em segundo plano

    dunst &

    echo -e "\nOpenbox detectado — dunst reiniciado... \n"

# Caso contrário, verifica se o ambiente é Wayland e usa o mako

elif [ -n "$WAYLAND_DISPLAY" ]; then

    # Mata qualquer instância antiga do mako

    pkill mako 2>/dev/null

    # Inicia o mako em segundo plano

    mako &

    echo -e "\nAmbiente Wayland detectado — mako iniciado... \n"

else

    echo -e "\nNenhum ambiente compatível detectado — nenhuma ação necessária.\n"

    sleep 5

fi






# ----------------------------------------------------------------------------------------


# Verifica se o yad está instalado

if ! command -v yad &> /dev/null; then

    echo -e "❌ O 'yad' não está instalado. Instale-o antes de continuar.

    No Debian/Ubuntu: sudo apt update && sudo apt install -y yad
    No Fedora: sudo dnf install yad
    No Void Linux: sudo xbps-install -Suvy yad"
    
    sleep 20
    
    exit 1
fi


# Verifica se o notify-send está instalado

if ! command -v notify-send &> /dev/null; then

    echo -e "\n❌ O notify-send não está instalado. Instale-o antes de continuar. \n"
    
    sleep 10
    
    exit 1
fi

# ----------------------------------------------------------------------------------------

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

        # Arquivo de log

        log="$nome_base.log"


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

        echo -e "
        ----------------------------------------
        Extraindo: $arquivo
        Destino:   $pasta_extraida
        ----------------------------------------
        "

        notify-send "Extração iniciada" "$arquivo → $pasta_extraida"

        notify-send "Extração iniciada" "$arquivo → $pasta_extraida"

        case "$arquivo" in

            *.tar.zst)  tar --zstd -xvf "$arquivo" -C "$pasta_extraida" 2> "$log" ;;
            *.tar.bz2)  tar xvjf "$arquivo" -C "$pasta_extraida" 2> "$log" ;;
            *.tar.gz)   tar xvzf "$arquivo" -C "$pasta_extraida" 2> "$log" ;;
            *.tar.xz)   tar xvJf "$arquivo" -C "$pasta_extraida" 2> "$log" ;;
            *.tbz2)     tar xvjf "$arquivo" -C "$pasta_extraida" 2> "$log" ;;
            *.tgz)      tar xvzf "$arquivo" -C "$pasta_extraida" 2> "$log" ;;
            *.tar)      tar xvf "$arquivo" -C "$pasta_extraida"  2> "$log" ;;
            *.zip)      unzip -o "$arquivo" -d "$pasta_extraida" 2> "$log" ;;
            *.rar)      unrar x -ad "$arquivo" "$pasta_extraida" 2> "$log" ;;
            *.7z)       7z x "$arquivo" -o"$pasta_extraida" 2> "$log" ;;
            *.bz2)      cp "$arquivo" "$pasta_extraida" && bunzip2 "$pasta_extraida/$nome_base" 2> "$log" ;;
            *.gz)       cp "$arquivo" "$pasta_extraida" && gunzip "$pasta_extraida/$nome_base"  2> "$log" ;;
            *.xz)       cp "$arquivo" "$pasta_extraida" && unxz "$pasta_extraida/$nome_base"    2> "$log" ;;
            *.zst)      cp "$arquivo" "$pasta_extraida" && unzstd "$pasta_extraida/$nome_base"  2> "$log" ;;
            *.lz4)      cp "$arquivo" "$pasta_extraida" && lz4 -d "$pasta_extraida/$nome_base" "${pasta_extraida}/${nome_sem_extensao}" 2> "$log" ;;
            *.lzma)     cp "$arquivo" "$pasta_extraida" && unlzma "$pasta_extraida/$nome_base"     2> "$log" ;;
            *.Z)        cp "$arquivo" "$pasta_extraida" && uncompress "$pasta_extraida/$nome_base" 2> "$log" ;;
            *.cab)      cabextract -d "$pasta_extraida" "$arquivo" 2> "$log" ;;
            *.iso)      7z x "$arquivo" -o"$pasta_extraida"        2> "$log" ;;
            *)          
                        echo -e "\n⚠️ Tipo de arquivo não suportado: $arquivo \n"

                        notify-send "Aviso" "Tipo de arquivo não suportado: $arquivo"
            ;;

        esac


        if [ $? -eq 0 ]; then
        
            # Tem certeza que deseja excluir o arquivo?

# Evitar exclusões acidentais

# Um clique errado ou uma confusão de nomes pode levar o usuário a apagar algo importante.
# Por isso, confirmar a ação reduz o risco de perda irreversível de informações.

# Baseado na prevenção de erros. (Jakob Nielsen)

# A boa prática de design manda que ações destrutivas peçam confirmação explícita.

# O sistema deve sempre manter o usuário informado sobre o que está acontecendo. (Jakob Nielsen)


            # Pergunta via YAD se o usuário deseja remover
            
            yad \
                --center \
                --title="Remover arquivo original?" \
                --question \
                --text="Deseja remover o arquivo original?\n\n$arquivo" \
                --buttons-layout=center \
                --button="Sim:0" --button="Não:1" \
                --width="500" --height="150" \
                2> /dev/null
            
            if [ $? -eq 0 ]; then

                rm -f "$arquivo" 2>> "$log"

                echo -e "\n✅ Extraído e removido: $arquivo \n"

                notify-send "Arquivo removido" "$arquivo"

                notifica_final

            else

                echo -e "\n🟡 Arquivo mantido: $arquivo \n"

                notify-send "Arquivo mantido" "$arquivo"

                notifica_final
            fi

        else

            echo -e "\n⚠️ Erro ao extrair: $arquivo \n"

            notify-send "Erro" "Falha ao extrair: $arquivo"
        fi

    else

        echo -e "\nArquivo não encontrado: $arquivo \n"

        notify-send "Aviso" "Arquivo não encontrado: $arquivo"

    fi

done



# Se o log estiver vazio, remove

[ ! -s "$log" ] && rm -f "$log"


exit 0
