# Smart Restaurant
 Management System is a SaaS-based solution that enables restaurants to manage digital menus, receive orders in real time, and get instant notifications using socket technology. Customers scan a QR code to access the menu and place orders, while restaurant staff and admins are notified instantly without page refresh.
 This software is a SaaS-based restaurant management platform designed to streamline restaurant operations through digital menus, QR-based ordering, and real-time notifications. Customers access the menu by scanning a QR code and place orders directly from their devices. Once an order is submitted, the system instantly notifies the restaurant admin and kitchen staff using WebSocket technology.

The platform supports role-based access (Admin, Staff, Customer) and can be deployed individually for each restaurant. Both frontend and backend are provided as a complete package, allowing restaurants to host the system on their own servers (including cPanel environments).

file staracture 


lib/
├── main.dart
├── app/
│   ├── router.dart
│   └── providers.dart
├── core/
│   ├── models/
│   │   ├── product.dart
│   │   └── order.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── socket_service.dart
├── features/
│   ├── qr/
│   │   └── qr_scanner_page.dart
│   ├── menu/
│   │   └── menu_page.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   └── add_product_page.dart
│   ├── orders/
│   │   └── orders_page.dart
# Smart-Restaurant
