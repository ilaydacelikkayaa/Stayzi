import pika
import json
import logging
from datetime import datetime

# Logging ayarları
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def send_notification_message(message_data):
    """Notification queue'ya mesaj gönderir"""
    try:
        logger.info(f"📤 Notification gönderiliyor: {message_data.get('type', 'Bilinmiyor')} - {message_data.get('message', '')}")
        
        connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        channel = connection.channel()
        channel.queue_declare(queue='notification_queue', durable=True)
        
        channel.basic_publish(
            exchange='',
            routing_key='notification_queue',
            body=json.dumps(message_data),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Persistent message
            )
        )
        
        logger.info(f"✅ Notification mesajı başarıyla gönderildi")
        connection.close()
    except Exception as e:
        logger.error(f"❌ Notification mesaj gönderme hatası: {e}")

def send_billing_message(billing_data):
    """Billing queue'ya mesaj gönderir"""
    try:
        logger.info(f"💳 Billing mesajı gönderiliyor: {billing_data.get('type', 'Bilinmiyor')} - {billing_data.get('amount', '')} TL")
        
        connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        channel = connection.channel()
        channel.queue_declare(queue='billing_queue', durable=True)
        
        channel.basic_publish(
            exchange='',
            routing_key='billing_queue',
            body=json.dumps(billing_data),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Persistent message
            )
        )
        
        logger.info(f"✅ Billing mesajı başarıyla gönderildi")
        connection.close()
    except Exception as e:
        logger.error(f"❌ Billing mesaj gönderme hatası: {e}")

def send_booking_created_message(booking_data):
    """Rezervasyon oluşturulduğunda hem notification hem billing mesajları gönderir"""
    try:
        # Notification mesajı
        notification_data = {
            'type': 'booking_confirmation',
            'user_id': booking_data.get('user_id'),
            'listing_id': booking_data.get('listing_id'),
            'message': f"Rezervasyonunuz onaylandı! {booking_data.get('check_in_date', '')} - {booking_data.get('check_out_date', '')}",
            'timestamp': datetime.now().isoformat()
        }
        send_notification_message(notification_data)
        
        # Billing mesajı
        billing_data = {
            'type': 'booking_payment',
            'user_id': booking_data.get('user_id'),
            'listing_id': booking_data.get('listing_id'),
            'amount': booking_data.get('total_price'),
            'message': f"Rezervasyon ödeme işlemi başlatıldı - {booking_data.get('total_price', '')} TL",
            'timestamp': datetime.now().isoformat()
        }
        send_billing_message(billing_data)
        
    except Exception as e:
        logger.error(f"❌ Booking mesaj gönderme hatası: {e}")

def send_review_created_message(review_data):
    """Yorum oluşturulduğunda notification mesajı gönderir"""
    try:
        notification_data = {
            'type': 'new_review',
            'user_id': review_data.get('user_id'),
            'listing_id': review_data.get('listing_id'),
            'message': f"Yeni yorum eklendi: {review_data.get('rating', '')} yıldız",
            'timestamp': datetime.now().isoformat()
        }
        send_notification_message(notification_data)
        
    except Exception as e:
        logger.error(f"❌ Review mesaj gönderme hatası: {e}")

def send_payment_processed_message(payment_data):
    """Ödeme işlendiğinde billing mesajı gönderir"""
    try:
        billing_data = {
            'type': 'payment_processed',
            'user_id': payment_data.get('user_id'),
            'listing_id': payment_data.get('listing_id'),
            'amount': payment_data.get('amount'),
            'message': f"Ödeme işlemi tamamlandı - {payment_data.get('amount', '')} TL",
            'timestamp': datetime.now().isoformat()
        }
        send_billing_message(billing_data)
        
    except Exception as e:
        logger.error(f"❌ Payment mesaj gönderme hatası: {e}") 