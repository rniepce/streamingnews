import requests
import os
import json
from datetime import datetime

# --- CONFIGURAÇÕES ---
WATCHMODE_API_KEY = os.environ["WATCHMODE_API_KEY"]

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
    try:
        response = requests.get(url, params=params)
        return response.json()
    except Exception:
        return []

def main():
    print("--- Buscando lançamentos ---")
    releases = get_daily_releases()
    
    output_data = {
        "date": datetime.now().strftime('%Y-%m-%d'),
        "items": []
    }

    if not releases:
        print("Nenhum lançamento encontrado hoje.")
    else:
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
                # Remove duplicatas e formata
                services_list = list(set(available_in))
                services_str = ", ".join(services_list)
                imdb_link = f"https://www.imdb.com/title/{imdb_id}" if imdb_id else ""
                
                print(f"Encontrado: {title} em {services_str}")
                
                output_data["items"].append({
                    "title": title,
                    "services": services_str,
                    "imdb_link": imdb_link
                })
    
    # Salva no arquivo JSON
    os.makedirs("data", exist_ok=True)
    with open("data/releases.json", "w", encoding="utf-8") as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print(f"Salvo data/releases.json com {len(output_data['items'])} itens.")

if __name__ == "__main__":
    main()
