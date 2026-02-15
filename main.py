import requests
import os
from datetime import datetime, timedelta

# --- CONFIGURAÇÕES ---
WATCHMODE_API_KEY = os.environ["WATCHMODE_API_KEY"]
TELEGRAM_TOKEN = os.environ["TELEGRAM_TOKEN"]
TELEGRAM_CHAT_ID = os.environ["TELEGRAM_CHAT_ID"]

# IDs dos serviços no Watchmode (Região BR)
SERVICES = {
    203: "Netflix",
    457: "Max (HBO)",
    26:  "Prime Video",
    372: "Disney+",
    371: "Apple TV+",
    368: "Apple TV (Aluguel/iTunes)",
    444: "Mubi"
}

def get_daily_releases():
    """Pega lançamentos das últimas 24 horas."""
    url = "https://api.watchmode.com/v1/releases/"
    params = {
        "apiKey": WATCHMODE_API_KEY,
        "regions": "BR",
        "sort_by": "date_desc",
        "limit": 20
    }
    
    try:
        response = requests.get(url, params=params)
        data = response.json()
        return data.get("releases", [])
    except Exception as e:
        print(f"Erro na API Watchmode: {e}")
        return []

def get_details(title_id):
    """Pega detalhes para saber onde está passando."""
    url = f"https://api.watchmode.com/v1/title/{title_id}/sources/"
    params = {
        "apiKey": WATCHMODE_API_KEY,
        "regions": "BR"
    }
    response = requests.get(url, params=params)
    return response.json()

def send_telegram_message(message):
    """Envia mensagem via Telegram Bot."""
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    payload = {
        "chat_id": TELEGRAM_CHAT_ID,
        "text": message,
        "parse_mode": "Markdown"
    }
    requests.post(url, data=payload)

def main():
    print("--- Buscando lançamentos ---")
    releases = get_daily_releases()
    
    if not releases:
        print("Nenhum lançamento encontrado hoje.")
        return

    message_buffer = f"🎬 **Novidades do Dia ({datetime.now().strftime('%d/%m')})**\n\n"
    has_news = False

    for item in releases:
        title = item.get("title", "Desconhecido")
        title_id = item.get("id")
        imdb_id = item.get("imdb_id", "")
        
        # Consulta onde esse título está disponível
        sources = get_details(title_id)
        
        # Filtra apenas os serviços que nos interessam
        available_in = []
        for source in sources:
            source_id = source.get("source_id")
            if source_id in SERVICES:
                available_in.append(SERVICES[source_id])
        
        # Se estiver em um dos nossos streamings, adiciona à lista
        if available_in:
            has_news = True
            services_str = ", ".join(set(available_in))
            link = f"https://www.imdb.com/title/{imdb_id}" if imdb_id else "#"
            
            message_buffer += f"📺 *{title}*\n"
            message_buffer += f"└ 📱 {services_str}\n"
            message_buffer += f"└ 🔗 [Ficha no IMDB]({link})\n\n"

    if has_news:
        send_telegram_message(message_buffer)
        print("Notificação enviada com sucesso!")
    else:
        print("Lançamentos encontrados, mas fora dos streamings monitorados.")

if __name__ == "__main__":
    main()
