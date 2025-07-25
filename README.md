# 📱 Social Feed



---

## 🏗 Архитектура проекта

Приложение реализовано на основе архитектуры **MVVM + Clean Architecture** с использованием следующих принципов:

- **Разделение слоев**: `Domain`, `Data`, `Presentation`, `Infrastructure`.
- **Презентационный слой на основе MVVM**
- **Асинхронная загрузка данных** с помощью Alamofire.
- **Слой представления** построен программно через Auto Layout без использования Storyboard.

---

## 🖼 Скриншоты

| Рекомендации | Сохраненные | 
|---------------|----------------|
| ![screenshot1](https://github.com/gibbonch/Social-Feed/blob/4288788433ac80c9368960c645d0333c563fa56e/Screenshots/recs.png) | ![screenshot2](https://github.com/gibbonch/Social-Feed/blob/4288788433ac80c9368960c645d0333c563fa56e/Screenshots/stored.png) |

> Скриншоты находятся в папке `Screenshots/`.

---

## ⚙️ Используемые технологии

- **Swift**
- **UIKit**
- **Alamofire**
- **Auto Layout (программно)** – верстка без Storyboard
- **Xcode** – последняя стабильная версия

---

## 🛠 Инструкция по сборке

1. **Клонируйте репозиторий**:
   ```bash
   git clone https://github.com/gibbonch/Social-Feed.git
   cd project-name
   ```
   
2. **Установите зависимости**:
    ```bash
    pod install
    open ProjectName.xcworkspace
    ```
