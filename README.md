
![hacker-phone](https://github.com/user-attachments/assets/6e3c1c58-cb1f-42e5-baaf-67089d804dfc)

# 📱 Overview
The **FiveM Hacker Phone Black Market Trading System** is a comprehensive underground trading script designed for FiveM servers. This system allows players to access illegal merchandise through an advanced hacker phone interface, delivering a complete black market experience. Key features include dynamic inventory management, secure NPC deliveries, and compatibility with multiple frameworks.

[![YouTube Subscribe](https://img.shields.io/badge/YouTube-Subscribe-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=LI-lh9IooYY)
[![Discord](https://img.shields.io/badge/Discord-Join-blue?style=for-the-badge&logo=discord)](https://discord.gg/EkwWvFS)
[![Tebex Store](https://img.shields.io/badge/Tebex-Store-green?style=for-the-badge&logo=shopify)](https://eyestore.tebex.io/)

## ✨ Features
- **Digital Black Market**: Access a variety of illegal items via an immersive hacker phone interface.
- **Extensive Inventory**: Stock weapons, medical supplies, hacking tools, forged documents, and more.
- **Dynamic Stock System**: Manage real-time inventory with automatic stock depletion.
- **Secure Delivery Mechanics**: Utilize NPC-driven delivery vehicles with interactive collection points.
- **Multi-Framework Support**: Fully compatible with ESX and QBCore frameworks.
- **Server-Side Security**: All transactions are validated server-side to prevent exploitation.
- **Customizable Product Database**: Easily modify items, prices, descriptions, and images.
- **Optimization**: Low resource usage with efficient code structure.

## 📋 Requirements
- **FiveM Server**
- **ESX or QBCore Framework**
- **OneSync Enabled** (recommended)

## 🔧 Installation
1. Download the latest release.
2. Extract the folder to your server's `resources` directory.
3. Add the following line to your `server.cfg`:
   ```
   ensure es-hackphone ---Black-Market-Trading-System
   ```
4. Configure the `blackmarket.json` file to customize your product offerings.
5. Restart your server.

## ⚙️ Configuration
The main configuration file is `blackmarket.json`; use it to:
- Add or remove products
- Adjust pricing and stock levels
- Change product descriptions and images
- Create new product categories

### Example Configuration:
```json
{
    "model": "weapon_pistol50",
    "description": "Powerful and effective handgun.",
    "stock": 5,
    "image": "https://example.com/pistol.jpg",
    "price": 1200,
    "id": 1,
    "category": "weapons",
    "name": "Desert Eagle"
}
```

## 🎮 Usage
Players can access the black market through:
- **Command**: `You need to press the "J" key or you need an item called a hackphone.`
- **Item Usage**: Use the "hackphone" item from the inventory.
- **Designated Locations**: Visit marked locations on the map.

---

Feel free to contribute to the project or report issues through the GitHub Issues page. Enjoy the sophisticated underground experience!
