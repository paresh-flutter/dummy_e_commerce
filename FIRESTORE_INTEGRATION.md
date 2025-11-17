# Firestore Integration for E-commerce App

This document outlines the comprehensive Firestore integration that has been implemented to replace the REST API-based data storage with a real-time, scalable database solution.

## Overview

The app has been updated to use Cloud Firestore as the primary database while maintaining backward compatibility with the existing API and local storage fallbacks. This provides a robust, multi-layered data strategy.

## Architecture Changes

### Data Flow
1. **Primary**: Firestore Database
2. **Fallback**: REST API (existing)
3. **Emergency**: Local/Mock data

### New Services Created

#### 1. `FirestoreService` (`lib/services/firestore_service.dart`)
- **Purpose**: Core Firestore operations
- **Collections**:
  - `users` - User profiles
  - `products` - Product catalog
  - `orders` - Order history and tracking
  - `carts` - User shopping carts

#### 2. `FirestoreProductService` (`lib/services/firestore_product_service.dart`)
- **Purpose**: Product-specific Firestore operations
- **Features**:
  - Product CRUD operations
  - Category management
  - Search functionality
  - Sample data initialization

#### 3. `FirestoreCartService` (`lib/services/firestore_cart_service.dart`)
- **Purpose**: Cart management in Firestore
- **Features**:
  - Real-time cart synchronization
  - Cart validation
  - Local fallback support

#### 4. `FirestoreOrderService` (`lib/services/firestore_order_service.dart`)
- **Purpose**: Order management in Firestore
- **Features**:
  - Order creation and tracking
  - Status updates
  - Order statistics

## Updated Services

### `ProductService`
- **Enhanced**: Now uses Firestore as primary data source
- **Fallback**: API → Mock data
- **New Method**: `initializeSampleData()`

### `CartService`
- **Enhanced**: Firestore-first with API fallback
- **Real-time**: Cart changes sync immediately
- **Validation**: Ensures product availability and pricing

### `OrderRepository`
- **Enhanced**: Complete order lifecycle in Firestore
- **Features**: Enhanced tracking, payment details, shipping addresses

### `AuthenticationService`
- **Enhanced**: User profiles stored in Firestore
- **Auto-sync**: Profile creation and updates

## Data Models

### Firestore Collections Structure

#### Users Collection (`users`)
```javascript
{
  id: "user_id",
  email: "user@example.com",
  name: "User Name",
  photoUrl: "https://...",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Products Collection (`products`)
```javascript
{
  id: "product_id",
  title: "Product Title",
  name: "Product Name",
  image: "https://...",
  imageUrl: "https://...",
  price: 99.99,
  description: "Product description",
  category: "Electronics",
  rating: {
    rate: 4.5,
    count: 128
  },
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Orders Collection (`orders`)
```javascript
{
  id: "order_id",
  userId: "user_id",
  items: [
    {
      productId: "product_id",
      productName: "Product Name",
      productPrice: 99.99,
      productImage: "https://...",
      quantity: 2,
      unitPrice: 99.99,
      totalPrice: 199.98
    }
  ],
  total: 199.98,
  status: "pending",
  orderDate: Timestamp,
  shippingAddress: {
    id: "address_id",
    fullName: "John Doe",
    phoneNumber: "+1234567890",
    addressLine1: "123 Main St",
    addressLine2: "Apt 1",
    city: "City",
    state: "State",
    zipCode: "12345",
    country: "Country",
    label: "Home",
    isDefault: true
  },
  paymentDetails: {
    method: "creditCard",
    cardLastFour: "1234",
    cardBrand: "Visa",
    amount: 199.98,
    transactionDate: Timestamp
  },
  trackingHistory: [
    {
      status: "pending",
      timestamp: Timestamp,
      description: "Order placed successfully"
    }
  ],
  trackingNumber: "TRK123456789",
  estimatedDelivery: Timestamp
}
```

#### Carts Collection (`carts`)
```javascript
{
  userId: "user_id",
  items: [
    {
      productId: "product_id",
      quantity: 2
    }
  ],
  updatedAt: Timestamp
}
```

## Security Rules

### Recommended Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products are read-only for users, write for admins
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
                   request.auth.token.admin == true;
    }
    
    // Users can only access their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
                         resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && 
                    request.resource.data.userId == request.auth.uid;
    }
    
    // Users can only access their own cart
    match /carts/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Features

### Real-time Updates
- Cart changes sync across devices
- Order status updates in real-time
- Product availability updates

### Offline Support
- Local caching through Firestore
- Graceful fallback to API/mock data
- Automatic sync when connection restored

### Performance Optimizations
- Indexed queries for fast retrieval
- Pagination support for large datasets
- Efficient cart operations

### Error Handling
- Multi-layer fallback system
- Graceful degradation
- User-friendly error messages

## Sample Data

The integration includes automatic sample data initialization:
- 5 sample products across different categories
- Sample user profiles
- Example orders with full tracking

## Usage

### Initialization
Sample data is automatically initialized on app startup. To manually initialize:

```dart
final firestoreService = FirestoreService();
await firestoreService.initializeSampleData();
```

### Product Operations
```dart
final productService = ProductService();
// This now uses Firestore automatically
final products = await productService.fetchProducts();
```

### Cart Operations
```dart
final cartService = CartService();
// Real-time Firestore synchronization
await cartService.addToCart(
  userId: userId,
  productId: productId,
  quantity: 2,
);
```

### Order Operations
```dart
final orderRepository = OrderRepository();
// Full Firestore integration with tracking
final order = await orderRepository.createOrder(
  cartItems: cartItems,
  userId: userId,
  shippingAddress: address,
  paymentDetails: paymentDetails,
);
```

## Benefits

1. **Real-time Synchronization**: Changes appear instantly across devices
2. **Offline Capability**: Works without internet connection
3. **Scalability**: Handles growth from prototype to production
4. **Security**: Row-level security with Firestore rules
5. **Performance**: Optimized queries and caching
6. **Reliability**: Multi-layer fallback system

## Migration Notes

- Existing API calls remain functional as fallbacks
- No breaking changes to existing code
- Gradual migration possible
- Easy rollback if needed

## Testing

The integration maintains all existing functionality while adding Firestore capabilities. Test both online and offline scenarios to ensure proper fallback behavior.

## Next Steps

1. Configure Firestore security rules
2. Set up indexes for optimal performance
3. Monitor usage and optimize queries
4. Consider advanced features like real-time listeners
5. Implement admin functions for product management

This integration provides a solid foundation for a production-ready e-commerce application with modern, scalable data architecture.