# CrisisMesh 🚨

**CrisisMesh** is a fully decentralized, offline-first disaster-response and emergency triage platform. It combines a peer-to-peer (P2P) mesh network with **true on-device AI (Gemma 3 270M)** to coordinate life-saving medical triage when internet and cellular infrastructure completely fail.

---

## 🌟 Key Features & Breakthroughs

- **100% Offline On-Device AI Triage**: Powered by Google's **Gemma 3 270M** (`gemma3-270m-it-q8.task`), running natively on the device using Google MediaPipe `LlmInference` & LiteRT. Zero internet or cloud servers required.
- **P2P Mesh Network**: Operates over Wi-Fi Direct and Bluetooth Low Energy (BLE). Devices automatically form a dynamic mesh graph to pass emergency text, location markers, and photo alerts across nodes back to central hubs.
- **Hardware Acceleration**: Tested and verified on physical hardware (e.g., Nothing Phone 3a with Qualcomm Snapdragon 7s Gen 3 NPU), providing instant emergency assessment directly on edge chips.
- **Zero Scripted Fallbacks**: Completely dynamic AI response generation for injury assessment and actionable emergency first-aid advice.

---

## 🏗️ Architecture

```
                       +------------------------+
                       |    Victim / Rescuer    |
                       |  (Flutter UI Chat App) |
                       +-----------+------------+
                                   |
                          MethodChannel Bridge
                                   |
                       +-----------v------------+
                       |  Android Native Layer  |
                       |    (MainActivity.kt)   |
                       +-----------+------------+
                                   |
                           MediaPipe LiteRT
                                   |
                       +-----------v------------+
                       |   Gemma 3 270M Model   |
                       | (gemma3-270m-it-q8.task)|
                       +------------------------+
                                   |
                          P2P Mesh Broadcast
                                   |
            +----------------------+----------------------+
            |                                             |
  +---------v---------+                         +---------v---------+
  | Relay Node 1 (BLE)|                         |Relay Node 2 (Wi-Fi)|
  +-------------------+                         +-------------------+
```

---

## 📂 Project Structure

• `lib/chat/triage_engine.dart`: Implements the core LLM interaction and includes a critical **PHI scrubbing layer**, ensuring all user input is sanitized of Protected Health Information before being passed to the on-device model for triage assessment.
- `lib/chat/chat_controller.dart`: State management driving real-time chat UI, dynamic prompts, and response processing.
- `lib/services/mesh_service.dart`: P2P mesh network routing engine using Wi-Fi Direct & Bluetooth.
- `android/app/src/main/kotlin/com/example/crisismesh/MainActivity.kt`: Native Kotlin bridge executing Google MediaPipe `LlmInference` to run `gemma3-270m-it-q8.task` directly on device NPU/GPU.
- `android/app/src/main/assets/gemma.task`: Bundled quantized Gemma 3 270M model binary.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Android Studio & Android SDK
- Physical Android Device connected via USB Debugging.

### Installation & Execution
1. **Clone the repository**:
   ```bash
   git clone https://github.com/thebhoopesh-commits/crisismesh.git
   cd crisismesh
   ```
2. **Model Setup**:
   Place `gemma3-270m-it-q8.task` inside `android/app/src/main/assets/` named as `gemma.task`.
3. **Build & Run**:
   ```bash
   flutter pub get
   flutter build apk --debug
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```

---

## 📄 License
Licensed under the MIT License.
