# ============================================================
# SENTINELA · D4 — Computational Thinking with Python
# Global Solution 2026.1 · FIAP
# Dupla: Rafael & Charles
# ------------------------------------------------------------
# App CLI de monitoramento de eventos climaticos do SENTINELA.
# Cadastra leituras de estacoes, classifica risco de enchente,
# gera alertas e relatorios. Integra com o esquema do banco D3.
# ============================================================

import json
import os
from datetime import datetime

# ── CONFIGURACAO ─────────────────────────────────────────────────────────────
ARQUIVO_DADOS = "eventos_sentinela.json"
ARQUIVO_RELATORIO = "relatorio_sentinela.txt"

# Thresholds de classificacao de risco (mm de chuva em 24h)
# Alinhados com o threshold meteorologico usado no D3, D5, D7 e D8
LIMITE_BAIXO = 10.0     # ate 10mm  -> risco BAIXO
LIMITE_MEDIO = 30.0     # 10 a 30mm -> risco MEDIO
LIMITE_ALTO = 60.0      # 30 a 60mm -> risco ALTO
                        # acima de 60mm -> risco CRITICO

# Tipos de evento validos (mesmo vocabulario do D3)
TIPOS_VALIDOS = ["ENCHENTE", "SECA", "TEMPESTADE", "GRANIZO", "VENDAVAL"]


# ── PERSISTENCIA ─────────────────────────────────────────────────────────────
def carregar_eventos():
    """Carrega a lista de eventos do arquivo JSON. Retorna lista vazia se nao existir."""
    if not os.path.exists(ARQUIVO_DADOS):
        return []
    try:
        with open(ARQUIVO_DADOS, "r", encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError) as e:
        print(f"  [AVISO] Erro ao ler arquivo de dados: {e}")
        print("  Iniciando com lista vazia.")
        return []


def salvar_eventos(eventos):
    """Salva a lista de eventos no arquivo JSON em UTF-8."""
    try:
        with open(ARQUIVO_DADOS, "w", encoding="utf-8") as f:
            json.dump(eventos, f, ensure_ascii=False, indent=2)
        return True
    except IOError as e:
        print(f"  [ERRO] Nao foi possivel salvar: {e}")
        return False


# ── LOGICA DE NEGOCIO ────────────────────────────────────────────────────────
def classificar_risco(precipitacao_mm):
    """
    Classifica o nivel de risco com base na precipitacao em mm.
    Retorna tupla (nivel, nivel_alerta) alinhada com o D3.
    """
    if precipitacao_mm < LIMITE_BAIXO:
        return "BAIXO", "INFO"
    elif precipitacao_mm < LIMITE_MEDIO:
        return "MEDIO", "ATENCAO"
    elif precipitacao_mm < LIMITE_ALTO:
        return "ALTO", "PERIGO"
    else:
        return "CRITICO", "EMERGENCIA"


def gerar_mensagem_alerta(evento):
    """Gera a mensagem de alerta para um evento, no padrao SENTINELA."""
    nivel = evento["risco"]
    return (f"Risco {nivel} de {evento['tipo']} na regiao "
            f"{evento['regiao']} - precipitacao de "
            f"{evento['precipitacao_mm']:.1f}mm registrada")


def ler_float(mensagem, minimo=None, maximo=None):
    """Le um numero float do usuario com validacao de range e tratamento de erro."""
    while True:
        try:
            valor = float(input(mensagem).replace(",", "."))
            if minimo is not None and valor < minimo:
                print(f"  [ERRO] Valor deve ser >= {minimo}. Tente novamente.")
                continue
            if maximo is not None and valor > maximo:
                print(f"  [ERRO] Valor deve ser <= {maximo}. Tente novamente.")
                continue
            return valor
        except ValueError:
            print("  [ERRO] Digite um numero valido (ex: 45.2).")


# ── OPERACOES CRUD ───────────────────────────────────────────────────────────
def cadastrar_evento(eventos):
    """Cadastra um novo evento climatico (CREATE)."""
    print("\n--- CADASTRAR EVENTO CLIMATICO ---")

    regiao = input("  Regiao (ex: Porto Alegre): ").strip()
    if not regiao:
        print("  [ERRO] Regiao nao pode ser vazia.")
        return

    # Selecao de tipo com validacao
    print(f"  Tipos validos: {', '.join(TIPOS_VALIDOS)}")
    tipo = input("  Tipo de evento: ").strip().upper()
    if tipo not in TIPOS_VALIDOS:
        print(f"  [ERRO] Tipo invalido. Use um de: {', '.join(TIPOS_VALIDOS)}")
        return

    precipitacao = ler_float("  Precipitacao (mm): ", minimo=0, maximo=1000)
    temperatura = ler_float("  Temperatura (C): ", minimo=-20, maximo=60)
    umidade = ler_float("  Umidade (%): ", minimo=0, maximo=100)

    # Classifica o risco automaticamente
    risco, nivel_alerta = classificar_risco(precipitacao)

    # Gera novo ID (maior ID atual + 1)
    novo_id = max([e["id"] for e in eventos], default=0) + 1

    evento = {
        "id": novo_id,
        "regiao": regiao,
        "tipo": tipo,
        "precipitacao_mm": precipitacao,
        "temperatura_c": temperatura,
        "umidade_pct": umidade,
        "risco": risco,
        "nivel_alerta": nivel_alerta,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "confirmado": False
    }

    eventos.append(evento)
    salvar_eventos(eventos)

    print(f"\n  [OK] Evento #{novo_id} cadastrado com sucesso!")
    print(f"  >>> CLASSIFICACAO DE RISCO: {risco} ({nivel_alerta})")
    if risco in ("ALTO", "CRITICO"):
        print(f"  >>> ALERTA: {gerar_mensagem_alerta(evento)}")


def listar_eventos(eventos):
    """Lista todos os eventos cadastrados (READ)."""
    print("\n--- EVENTOS CADASTRADOS ---")
    if not eventos:
        print("  Nenhum evento cadastrado.")
        return

    print(f"  {'ID':<4} {'REGIAO':<18} {'TIPO':<12} {'CHUVA':<9} {'RISCO':<9} {'CONF':<5}")
    print("  " + "-" * 62)
    for e in eventos:
        conf = "SIM" if e["confirmado"] else "NAO"
        print(f"  {e['id']:<4} {e['regiao'][:17]:<18} {e['tipo']:<12} "
              f"{e['precipitacao_mm']:>6.1f}mm {e['risco']:<9} {conf:<5}")
    print(f"\n  Total: {len(eventos)} evento(s)")


def atualizar_evento(eventos):
    """Atualiza a precipitacao de um evento e reclassifica (UPDATE)."""
    print("\n--- ATUALIZAR EVENTO ---")
    if not eventos:
        print("  Nenhum evento para atualizar.")
        return

    listar_eventos(eventos)
    try:
        id_busca = int(input("\n  ID do evento a atualizar: "))
    except ValueError:
        print("  [ERRO] ID deve ser um numero.")
        return

    evento = next((e for e in eventos if e["id"] == id_busca), None)
    if not evento:
        print(f"  [ERRO] Evento #{id_busca} nao encontrado.")
        return

    nova_precip = ler_float(
        f"  Nova precipitacao (atual: {evento['precipitacao_mm']:.1f}mm): ",
        minimo=0, maximo=1000)

    evento["precipitacao_mm"] = nova_precip
    evento["risco"], evento["nivel_alerta"] = classificar_risco(nova_precip)
    evento["timestamp"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    salvar_eventos(eventos)
    print(f"\n  [OK] Evento #{id_busca} atualizado.")
    print(f"  >>> NOVA CLASSIFICACAO: {evento['risco']} ({evento['nivel_alerta']})")


def confirmar_alerta(eventos):
    """Marca um evento como confirmado por operador (fecha loop de governanca)."""
    print("\n--- CONFIRMAR ALERTA ---")
    if not eventos:
        print("  Nenhum evento para confirmar.")
        return

    listar_eventos(eventos)
    try:
        id_busca = int(input("\n  ID do evento a confirmar: "))
    except ValueError:
        print("  [ERRO] ID deve ser um numero.")
        return

    evento = next((e for e in eventos if e["id"] == id_busca), None)
    if not evento:
        print(f"  [ERRO] Evento #{id_busca} nao encontrado.")
        return

    evento["confirmado"] = True
    salvar_eventos(eventos)
    print(f"  [OK] Evento #{id_busca} confirmado pelo operador.")


def deletar_evento(eventos):
    """Remove um evento da lista (DELETE)."""
    print("\n--- DELETAR EVENTO ---")
    if not eventos:
        print("  Nenhum evento para deletar.")
        return

    listar_eventos(eventos)
    try:
        id_busca = int(input("\n  ID do evento a deletar: "))
    except ValueError:
        print("  [ERRO] ID deve ser um numero.")
        return

    evento = next((e for e in eventos if e["id"] == id_busca), None)
    if not evento:
        print(f"  [ERRO] Evento #{id_busca} nao encontrado.")
        return

    confirma = input(f"  Confirma exclusao do evento #{id_busca}? (s/n): ").lower()
    if confirma == "s":
        eventos.remove(evento)
        salvar_eventos(eventos)
        print(f"  [OK] Evento #{id_busca} removido.")
    else:
        print("  Operacao cancelada.")


# ── INDICADORES E RELATORIO ──────────────────────────────────────────────────
def exibir_indicadores(eventos):
    """Calcula e exibe indicadores agregados para tomada de decisao."""
    print("\n--- INDICADORES SENTINELA ---")
    if not eventos:
        print("  Nenhum evento para analisar.")
        return

    total = len(eventos)
    por_risco = {"BAIXO": 0, "MEDIO": 0, "ALTO": 0, "CRITICO": 0}
    por_tipo = {}
    soma_precip = 0.0
    maior_precip = 0.0
    regiao_critica = "-"

    for e in eventos:
        por_risco[e["risco"]] = por_risco.get(e["risco"], 0) + 1
        por_tipo[e["tipo"]] = por_tipo.get(e["tipo"], 0) + 1
        soma_precip += e["precipitacao_mm"]
        if e["precipitacao_mm"] > maior_precip:
            maior_precip = e["precipitacao_mm"]
            regiao_critica = e["regiao"]

    media_precip = soma_precip / total
    criticos = por_risco["ALTO"] + por_risco["CRITICO"]

    print(f"  Total de eventos          : {total}")
    print(f"  Precipitacao media        : {media_precip:.1f}mm")
    print(f"  Maior precipitacao        : {maior_precip:.1f}mm ({regiao_critica})")
    print(f"  Eventos de alto risco     : {criticos} ({criticos/total*100:.0f}%)")
    print("\n  Distribuicao por risco:")
    for nivel, qtd in por_risco.items():
        barra = "#" * qtd
        print(f"    {nivel:<9}: {qtd:>3} {barra}")
    print("\n  Distribuicao por tipo:")
    for tipo, qtd in sorted(por_tipo.items(), key=lambda x: -x[1]):
        print(f"    {tipo:<12}: {qtd}")


def gerar_relatorio(eventos):
    """Gera relatorio completo em arquivo .txt."""
    print("\n--- GERAR RELATORIO ---")
    if not eventos:
        print("  Nenhum evento para relatar.")
        return

    try:
        with open(ARQUIVO_RELATORIO, "w", encoding="utf-8") as f:
            f.write("=" * 60 + "\n")
            f.write("RELATORIO SENTINELA - MONITORAMENTO CLIMATICO\n")
            f.write("Global Solution 2026.1 - FIAP\n")
            f.write(f"Gerado em: {datetime.now().strftime('%d/%m/%Y %H:%M:%S')}\n")
            f.write("=" * 60 + "\n\n")

            total = len(eventos)
            criticos = sum(1 for e in eventos if e["risco"] in ("ALTO", "CRITICO"))
            media = sum(e["precipitacao_mm"] for e in eventos) / total

            f.write("RESUMO EXECUTIVO\n")
            f.write("-" * 60 + "\n")
            f.write(f"Total de eventos monitorados : {total}\n")
            f.write(f"Eventos de alto risco        : {criticos}\n")
            f.write(f"Precipitacao media           : {media:.1f}mm\n\n")

            f.write("DETALHAMENTO DOS EVENTOS\n")
            f.write("-" * 60 + "\n")
            for e in eventos:
                f.write(f"\nEvento #{e['id']} - {e['timestamp']}\n")
                f.write(f"  Regiao       : {e['regiao']}\n")
                f.write(f"  Tipo         : {e['tipo']}\n")
                f.write(f"  Precipitacao : {e['precipitacao_mm']:.1f}mm\n")
                f.write(f"  Temperatura  : {e['temperatura_c']:.1f}C\n")
                f.write(f"  Umidade      : {e['umidade_pct']:.1f}%\n")
                f.write(f"  RISCO        : {e['risco']} ({e['nivel_alerta']})\n")
                f.write(f"  Confirmado   : {'SIM' if e['confirmado'] else 'NAO'}\n")
                if e["risco"] in ("ALTO", "CRITICO"):
                    f.write(f"  >>> ALERTA: {gerar_mensagem_alerta(e)}\n")

            f.write("\n" + "=" * 60 + "\n")
            f.write("Fim do relatorio - SENTINELA\n")

        print(f"  [OK] Relatorio gerado: {ARQUIVO_RELATORIO}")
    except IOError as e:
        print(f"  [ERRO] Nao foi possivel gerar relatorio: {e}")


# ── MENU PRINCIPAL ───────────────────────────────────────────────────────────
def exibir_menu():
    """Exibe o menu principal."""
    print("\n" + "=" * 50)
    print("   SENTINELA - MONITORAMENTO CLIMATICO")
    print("   Sistema de Prevencao de Desastres")
    print("=" * 50)
    print("  1 - Cadastrar evento")
    print("  2 - Listar eventos")
    print("  3 - Atualizar evento")
    print("  4 - Confirmar alerta")
    print("  5 - Deletar evento")
    print("  6 - Ver indicadores")
    print("  7 - Gerar relatorio (.txt)")
    print("  0 - Sair")
    print("=" * 50)


def main():
    """Funcao principal - loop do menu."""
    eventos = carregar_eventos()
    print("\n  Sistema SENTINELA iniciado.")
    print(f"  {len(eventos)} evento(s) carregado(s).")

    while True:
        exibir_menu()
        try:
            opcao = input("  Escolha uma opcao: ").strip()
        except (KeyboardInterrupt, EOFError):
            print("\n  Encerrando...")
            break

        if opcao == "1":
            cadastrar_evento(eventos)
        elif opcao == "2":
            listar_eventos(eventos)
        elif opcao == "3":
            atualizar_evento(eventos)
        elif opcao == "4":
            confirmar_alerta(eventos)
        elif opcao == "5":
            deletar_evento(eventos)
        elif opcao == "6":
            exibir_indicadores(eventos)
        elif opcao == "7":
            gerar_relatorio(eventos)
        elif opcao == "0":
            print("\n  Encerrando o SENTINELA. Ate logo!")
            break
        else:
            print("  [ERRO] Opcao invalida. Escolha de 0 a 7.")


if __name__ == "__main__":
    main()
