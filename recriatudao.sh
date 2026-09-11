#!/bin/bash
#
#######################
#    ^...^  `^...^´   #
#   /_o,o_\ /_O,O_\   #
#   |):::(| |):::(|   #
# ====" "=====" "==== #
#         TdC         #
#      1998-2026      #
#######################
#
# Toca das Corujas
# Códigos Binários,
# Funções de Onda e
# Teoria do Orbital Molecular Inc.
# Unidade Barão Geraldo CX
#
# 
# Impede a execução com sh
if [ -z "${BASH_VERSION:-}" ]; then
    echo "Execute este script com Bash:"
    echo "bash $0"
    exit 1
fi

RAIZ="$(pwd)"
ARQUIVO_TUDO="$RAIZ/tudo.txt"

# Renomeia todos os arquivos .svg para .txt
renomear_para_txt() {
    while IFS= read -r -d '' arquivo; do
        novo_nome="${arquivo%.svg}.txt"

        if [ -e "$novo_nome" ]; then
            echo "Já existe, ignorando: $novo_nome"
        else
            mv -- "$arquivo" "$novo_nome"
            echo "Renomeado: ${arquivo#$RAIZ/}"
        fi
    done < <(
        find "$RAIZ" \
            -type f \
            -name "*.svg" \
            -print0
    )
}

# Cria um único tudo.txt na raiz com todos os arquivos .txt
criar_tudo_txt() {
    : > "$ARQUIVO_TUDO"

    while IFS= read -r -d '' arquivo; do
        caminho_relativo="${arquivo#$RAIZ/}"

        printf '=== ARQUIVO: %s ===\n' "$caminho_relativo" >> "$ARQUIVO_TUDO"
        cat -- "$arquivo" >> "$ARQUIVO_TUDO"
        printf '\n\n' >> "$ARQUIVO_TUDO"

    done < <(
        find "$RAIZ" \
            -type f \
            -name "*.txt" \
            ! -path "$ARQUIVO_TUDO" \
            -print0
    )

    echo "Criado: $ARQUIVO_TUDO"
}

criar_tudo_svg() {
    : > "$ARQUIVO_TUDO"

    while IFS= read -r -d '' arquivo; do
        caminho_relativo="${arquivo#$RAIZ/}"

        printf '=== ARQUIVO: %s ===\n' "$caminho_relativo" >> "$ARQUIVO_TUDO"
        cat -- "$arquivo" >> "$ARQUIVO_TUDO"
        printf '\n\n' >> "$ARQUIVO_TUDO"

    done < <(
        find "$RAIZ" \
            -type f \
            -name "*.svg" \
            ! -path "$ARQUIVO_TUDO" \
            -print0
    )

    echo "Criado: $ARQUIVO_TUDO"
}

# Recria os arquivos usando o tudo.txt da raiz
recriar_arquivos() {
    if [ ! -f "$ARQUIVO_TUDO" ]; then
        echo "Erro: o arquivo tudo.txt não existe na raiz."
        return 1
    fi

    local nome_arquivo=""
    local conteudo=""
    local linha
    local caminho_completo

    while IFS= read -r linha || [ -n "$linha" ]; do

        if [[ "$linha" =~ ^===\ ARQUIVO:\ (.*)\ ===$ ]]; then

            # Salva o arquivo anterior
            if [ -n "$nome_arquivo" ]; then
                caminho_completo="$RAIZ/$nome_arquivo"

                mkdir -p -- "$(dirname -- "$caminho_completo")"
                printf '%s' "$conteudo" > "$caminho_completo"

                echo "Recriado: $nome_arquivo"
            fi

            nome_arquivo="${BASH_REMATCH[1]}"
            conteudo=""

        else
            conteudo+="$linha"$'\n'
        fi

    done < "$ARQUIVO_TUDO"

    # Salva o último arquivo
    if [ -n "$nome_arquivo" ]; then
        caminho_completo="$RAIZ/$nome_arquivo"

        mkdir -p -- "$(dirname -- "$caminho_completo")"
        printf '%s' "$conteudo" > "$caminho_completo"

        echo "Recriado: $nome_arquivo"
    fi
}

recria_links(){
    find . -type l -exec sh -c '
for link do
    dir=$(dirname "$link")
    nome=$(basename "$link")
    printf "%s\n" "$nome" >> "$dir/.hidden"
done
' sh {} +
}


# Renomeia todos os arquivos .txt para .svg
renomear_para_svg() {
    while IFS= read -r -d '' arquivo; do
        # Nunca renomeia o arquivo principal tudo.txt
        [ "$arquivo" = "$ARQUIVO_TUDO" ] && continue

        novo_nome="${arquivo%.txt}.svg"

        if [ -e "$novo_nome" ]; then
            echo "Já existe, ignorando: $novo_nome"
        else
            mv -- "$arquivo" "$novo_nome"
            chmod 644 -- "$novo_nome"
            echo "Renomeado: ${arquivo#$RAIZ/}"
        fi
    done < <(
        find "$RAIZ" \
            -type f \
            -name "*.txt" \
            -print0
    )
}

# Menu principal
echo "Selecione a opção:"
echo "1 - Renomear arquivos .svg para .txt"
echo "2 - Criar tudo.txt na raiz com arquivos de todas as pastas"
echo "3 - Recriar arquivos a partir de tudo.txt"
echo "4 - Renomear arquivos .txt para .svg"
echo "5 - Criar tudo.txt com os svg"
echo "6 - 1, 2 e 4"

read -r -p "Opção: " opcao

case "$opcao" in
    1)
        renomear_para_txt
        ;;

    2)
        criar_tudo_txt
        ;;

    3)
        recriar_arquivos
        recria_links
        ;;

    4)
        renomear_para_svg
        ;;

    5)
        criar_tudo_svg
#        renomear_para_txt
#        criar_tudo_txt
#        recriar_arquivos
#        renomear_para_svg
        ;;

    6)
        renomear_para_txt
        criar_tudo_txt
        renomear_para_svg
        ;;

    *)
        echo "Opção inválida."
        exit 1
        ;;
esac

echo "Operação concluída."
