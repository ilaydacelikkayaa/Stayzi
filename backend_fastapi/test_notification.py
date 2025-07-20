import json
import pika
import time
from datetime import datetime, timedelta

def send_test_message(queue_name, message_data):
    """Test mesajı gönderir"""
    try:
        print(f"🐰 {queue_name} queue'ya test mesajı gönderiliyor...")
        
        connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        channel = connection.channel()
        channel.queue_declare(queue=queue_name, durable=True)
        
        channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=json.dumps(message_data),
            properties=pika.BasicProperties(
                delivery_mode=2,  # Persistent message
            )
        )
        
        print(f"✅ {queue_name} test mesajı başarıyla gönderildi")
        connection.close()
        return True
        
    except Exception as e:
        print(f"❌ {queue_name} test mesajı gönderme hatası: {e}")
        return False

def test_notification_service():
    """Notification service'i test eder"""
    print("\n" + "="*50)
    print("📧 NOTIFICATION SERVICE TEST")
    print("="*50)
    
    # Test 1: Rezervasyon onay bildirimi
    booking_notification = {
        'type': 'booking_confirmation',
        'user_id': 1,
        'listing_id': 6,
        'message': f'Rezervasyonunuz onaylandı! {(datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")} - {(datetime.now() + timedelta(days=3)).strftime("%Y-%m-%d")}',
        'timestamp': datetime.now().isoformat()
    }
    send_test_message('notification_queue', booking_notification)
    
    time.sleep(2)
    
    # Test 2: Yeni yorum bildirimi
    review_notification = {
        'type': 'new_review',
        'user_id': 2,
        'listing_id': 6,
        'message': 'Yeni yorum eklendi: 5 yıldız',
        'timestamp': datetime.now().isoformat()
    }
    send_test_message('notification_queue', review_notification)
    
    time.sleep(2)
    
    # Test 3: Ödeme başarı bildirimi
    payment_notification = {
        'type': 'payment_success',
        'user_id': 1,
        'listing_id': 6,
        'message': 'Ödemeniz başarıyla alındı',
        'timestamp': datetime.now().isoformat()
    }
    send_test_message('notification_queue', payment_notification)

def test_billing_service():
    """Billing service'i test eder"""
    print("\n" + "="*50)
    print("💳 BILLING SERVICE TEST")
    print("="*50)
    
    # Test 1: Rezervasyon ödeme işlemi
    booking_payment = {
        'type': 'booking_payment',
        'user_id': 1,
        'listing_id': 6,
        'amount': 1500.00,
        'message': 'Rezervasyon ödeme işlemi başlatıldı - 1500.00 TL',
        'timestamp': datetime.now().isoformat()
    }
    send_test_message('billing_queue', booking_payment)
    
    time.sleep(2)
    
    # Test 2: Ödeme işlemi tamamlandı
    payment_processed = {
        'type': 'payment_processed',
        'user_id': 1,
        'listing_id': 6,
        'amount': 1500.00,
        'message': 'Ödeme işlemi tamamlandı - 1500.00 TL',
        'timestamp': datetime.now().isoformat()
    }
    send_test_message('billing_queue', payment_processed)
    
    time.sleep(2)
    
    # Test 3: İade talebi
    refund_request = {
        'type': 'refund_request',
        'user_id': 1,
        'listing_id': 6,
        'amount': 750.00,
        'message': 'İade talebi alındı - 750.00 TL',
        'timestamp': datetime.now().isoformat()
    }
    send_test_message('billing_queue', refund_request)

def main():
    """Ana test fonksiyonu"""
    print("🧪 RABBITMQ TEST SERVİSLERİ")
    print("="*50)
    print("Bu script hem notification hem de billing service'leri test eder.")
    print("Her iki service'in de çalıştığından emin olun:")
    print("1. python app/services/notification_service.py")
    print("2. python app/services/billing_service.py")
    print("="*50)
    
    # Notification service test
    test_notification_service()
    
    # Billing service test
    test_billing_service()
    
    print("\n" + "="*50)
    print("✅ Tüm test mesajları gönderildi!")
    print("📧 Notification service terminal'inde mesajları kontrol edin")
    print("💳 Billing service terminal'inde mesajları kontrol edin")
    print("="*50)

if __name__ == "__main__":
    main() 