import pika
import json
import time
import logging
from datetime import datetime

# Logging ayarları
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def callback(ch, method, properties, body):
    """Mesaj alındığında çağrılan callback fonksiyonu"""
    try:
        data = json.loads(body.decode('utf-8'))
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        logger.info(f"📨 Yeni mesaj alındı [{timestamp}]:")
        logger.info(f"   📋 Tip: {data.get('type', 'Bilinmiyor')}")
        logger.info(f"   👤 Kullanıcı ID: {data.get('user_id', 'Bilinmiyor')}")
        logger.info(f"   🏠 İlan ID: {data.get('listing_id', 'Bilinmiyor')}")
        logger.info(f"   💰 Tutar: {data.get('amount', 'Bilinmiyor')} TL")
        logger.info(f"   📝 Mesaj: {data.get('message', 'Bilinmiyor')}")
        
        # Mesaj tipine göre işlem yap
        message_type = data.get('type', '')
        if message_type == 'booking_payment':
            logger.info("💳 Rezervasyon ödeme işlemi başlatıldı")
            logger.info("📊 Fatura oluşturuluyor...")
            logger.info("✅ Fatura başarıyla oluşturuldu")
        elif message_type == 'payment_processed':
            logger.info("💰 Ödeme işlemi tamamlandı")
            logger.info("📧 Fatura e-postası gönderiliyor...")
            logger.info("✅ Fatura e-postası gönderildi")
        elif message_type == 'refund_request':
            logger.info("🔄 İade talebi alındı")
            logger.info("📋 İade işlemi başlatılıyor...")
            logger.info("✅ İade işlemi tamamlandı")
        else:
            logger.info(f"📌 Bilinmeyen mesaj tipi: {message_type}")
        
        # Mesajı onayla
        ch.basic_ack(delivery_tag=method.delivery_tag)
        
    except json.JSONDecodeError as e:
        logger.error(f"❌ JSON parse hatası: {e}")
        ch.basic_ack(delivery_tag=method.delivery_tag)
    except Exception as e:
        logger.error(f"❌ Mesaj işleme hatası: {e}")
        ch.basic_ack(delivery_tag=method.delivery_tag)

def connect_to_rabbitmq():
    """RabbitMQ'ya bağlanır"""
    try:
        # Bağlantı parametreleri
        connection_params = pika.ConnectionParameters(
            host='localhost',
            port=5672,
            virtual_host='/',
            credentials=pika.PlainCredentials('guest', 'guest'),
            heartbeat=600,
            blocked_connection_timeout=300
        )
        
        logger.info("🔗 RabbitMQ'ya bağlanılıyor...")
        connection = pika.BlockingConnection(connection_params)
        channel = connection.channel()
        
        # Queue'yu tanımla
        queue_name = 'billing_queue'
        channel.queue_declare(queue=queue_name, durable=True)
        
        # QoS ayarları
        channel.basic_qos(prefetch_count=1)
        
        # Consumer'ı başlat
        channel.basic_consume(
            queue=queue_name,
            on_message_callback=callback,
            auto_ack=False  # Manuel onay
        )
        
        logger.info(f"✅ RabbitMQ'ya başarıyla bağlandı")
        logger.info(f"📧 Queue: {queue_name}")
        logger.info("🎧 Mesajlar dinleniyor... (Ctrl+C ile çıkış)")
        
        return connection, channel
        
    except pika.exceptions.AMQPConnectionError as e:
        logger.error(f"❌ RabbitMQ bağlantı hatası: {e}")
        logger.error("💡 RabbitMQ'nun çalıştığından emin olun:")
        logger.error("   docker-compose up -d")
        return None, None
    except Exception as e:
        logger.error(f"❌ Beklenmeyen hata: {e}")
        return None, None

def main():
    """Ana fonksiyon"""
    logger.info("🚀 Billing Service başlatılıyor...")
    
    connection, channel = connect_to_rabbitmq()
    if not connection or not channel:
        logger.error("❌ RabbitMQ bağlantısı kurulamadı")
        return
    
    try:
        # Mesajları dinlemeye başla
        channel.start_consuming()
    except KeyboardInterrupt:
        logger.info("⏹️ Billing Service durduruluyor...")
    except pika.exceptions.ConnectionClosedByBroker as e:
        logger.error(f"❌ RabbitMQ bağlantısı kesildi: {e}")
    except Exception as e:
        logger.error(f"❌ Beklenmeyen hata: {e}")
    finally:
        if connection and not connection.is_closed:
            connection.close()
            logger.info("🔌 Bağlantı kapatıldı")

if __name__ == "__main__":
    main() 