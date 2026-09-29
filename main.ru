import os
import telebot
import google.generativeai as genai

# Бот берет токены из настроек сервера
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
GEMINI_KEY = os.getenv("GEMINI_KEY")

bot = telebot.TeleBot(TELEGRAM_TOKEN)
genai.configure(api_key=GEMINI_KEY)

model = genai.GenerativeModel("gemini-1.5-flash")

# Строгий промт для оценки внешности (Looksmaxing)
LOOKSMAXXING_PROMPT = """
Ты — абсолютно объективный, честный и бескомпромиссный эксперт по оценке внешности (looksmaxing). Оценивай фото строго, честно, без подлизывания и фальшивых комплиментов.

Выдай разбор строго по этой структуре:

1. Честный рейд (шкала 0-7):
Укажи категорию: Sub 3, Sub 5 (LTN), MTN, High MTN, HTN, Chadlite / Stacy-lite, Chad / True Model.

2. Разбор зон:
- Зона глаз (canthal tilt, верхнее веко, синяки/мешки).
- Челюсть и подбородок (выраженность, углы, гармония).
- Кожа и ухоженность.
- Прическа (подходит ли под форму лица).

3. Потенциал и советы:
- Потенциал (какой максимум можно выжать).
- Нужны ли кремы/уход за кожей или все отлично.
- Какая прическа подойдет лучше.
- Рекомендации по проценту жира (BF%) или другим деталям. Если менять ничего не нужно — напиши прямо.
"""

@bot.message_handler(commands=['start'])
def start_message(message):
    bot.reply_to(message, "👋 Привет! Отправь мне свое фото, и я сделаю объективный и строгий разбор внешности по критериям Looksmaxing!")

@bot.message_handler(content_types=['photo'])
def handle_photo(message):
    try:
        status_msg = bot.reply_to(message, "⏳ Анализирую фото...")

        # Скачиваем отправленное фото
        file_info = bot.get_file(message.photo[-1].file_id)
        downloaded_file = bot.download_file(file_info.file_path)

        image_data = {
            "mime_type": "image/jpeg",
            "data": downloaded_file
        }

        # Отправляем фото и промт в нейросеть
        response = model.generate_content([LOOKSMAXXING_PROMPT, image_data])

        # Отправляем результат пользователю
        bot.reply_to(message, response.text, parse_mode="Markdown")
        bot.delete_message(message.chat.id, status_msg.message_id)

    except Exception as e:
        bot.reply_to(message, f"❌ Ошибка при обработке фото: {str(e)}")

if __name__ == "__main__":
    print("Бот запущен!")
    bot.infinity_polling()