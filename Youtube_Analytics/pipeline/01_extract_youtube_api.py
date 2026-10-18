import os
import pandas as pd
import isodate
from googleapiclient.discovery import build

# ==========================================
# CONFIGURACIÓN
# ==========================================
API_KEY = ""

# Construir el cliente del servicio
youtube = build("youtube", "v3", developerKey=API_KEY)

def extraer_videos_musicales(max_resultados=200):
    print("Iniciando extracción de datos desde YouTube Data API v3...")
    
    videos_data = []
    next_page_token = None
    
    # 1. Buscar videos de música publicados en el primer semestre de 2026
    while len(videos_data) < max_resultados:
        request_search = youtube.search().list(
            part="id,snippet",
            q="music",                          # Búsqueda general musical
            type="video",
            videoCategoryId="10",               # Categoría 10 = Música
            publishedAfter="2026-01-01T00:00:00Z",
            publishedBefore="2026-06-30T23:59:59Z",
            maxResults=min(50, max_resultados - len(videos_data)),
            pageToken=next_page_token
        )
        response_search = request_search.execute()
        
        # Extraer los IDs de los videos devueltos
        video_ids = [item["id"]["videoId"] for item in response_search.get("items", []) if "videoId" in item["id"]]
        
        if not video_ids:
            break
            
        # 2. Consultar las estadísticas y detalles completos de esos videos
        request_details = youtube.videos().list(
            part="snippet,contentDetails,statistics",
            id=",".join(video_ids)
        )
        response_details = request_details.execute()
        
        # 3. Mapear cada campo a nuestro esquema de datos
        for item in response_details.get("items", []):
            snippet = item.get("snippet", {})
            stats = item.get("statistics", {})
            content = item.get("contentDetails", {})
            
            # Parsear duración ISO (ej: PT3M45S) a segundos enteros
            duracion_iso = content.get("duration", "PT0S")
            try:
                duracion_segundos = int(isodate.parse_duration(duracion_iso).total_seconds())
            except Exception:
                duracion_segundos = 0

            videos_data.append({
                "video_id": item.get("id"),
                "titulo": snippet.get("title"),
                "id_canal": snippet.get("channelId"),
                "nombre_canal": snippet.get("channelTitle"),
                "fecha_publicacion": snippet.get("publishedAt"),
                "duracion_segundos": duracion_segundos,
                "vistas": stats.get("viewCount", 0),
                "likes": stats.get("likeCount", 0),
                "comentarios": stats.get("commentCount", 0)
            })
            
        next_page_token = response_search.get("nextPageToken")
        if not next_page_token:
            break  # No hay más páginas disponibles

    # 4. Guardar en un DataFrame y exportar a CSV
    df = pd.DataFrame(videos_data)
    nombre_archivo = "raw_youtube_music_2026.csv"
    df.to_csv(nombre_archivo, index=False, encoding="utf-8-sig")
    
    print(f" Extracción finalizada con éxito.")
    print(f" Total de registros obtenidos: {len(df)}")
    print(f" Archivo generado: {nombre_archivo}")

if __name__ == "__main__":
    extraer_videos_musicales(max_resultados=200)