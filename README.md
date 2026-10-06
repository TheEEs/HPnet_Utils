# Tiện ích HPNET (HPNET Utility)

[🇻🇳 Tiếng Việt](#tiếng-việt) | [🇬🇧 English](#english)

---

<a name="tiếng-việt"></a>
## 🇻🇳 TIẾNG VIỆT

**Tiện ích HPNET** là một ứng dụng desktop gọn nhẹ, đa nền tảng được phát triển bằng ngôn ngữ **Ruby** và **Glimmer DSL for LibUI**. Ứng dụng này tự động hóa việc tương tác với cổng thông tin/văn bản hành chính HPNET (hệ thống ASP.NET) tại Việt Nam, giúp cán bộ và lãnh đạo xử lý văn bản, tờ trình hành chính nhanh chóng và hiệu quả hơn thông qua tự động hóa quy trình (RPA) kết hợp với trí tuệ nhân tạo (AI - Gemini 3.1).

---

### 🌟 Tính Năng Nổi Bật

1. **Giao Diện Đồ Họa Bản Địa (Native GUI)**
   - Xây dựng trên nền tảng **Glimmer DSL for LibUI**, đem lại giao diện desktop nguyên bản của hệ điều hành (Windows, macOS, Linux).
   - Khởi động cực nhanh, tiêu tốn ít RAM và tài nguyên hệ thống so với các giải pháp Electron hoặc trình duyệt web thông thường.

2. **Trình Văn Bản Hàng Loạt (Batch Document Submission)**
   - Tự động tải lên các văn bản kèm theo thông tin trích yếu và chỉ định lãnh đạo duyệt chỉ trong vài thao tác đơn giản.

3. **Chuyển Duyệt Văn Bản Hàng Loạt (Batch Forwarding & Approval)**
   - Cho phép lọc và duyệt văn bản hàng loạt dựa trên từ khóa tìm kiếm.
   - Hiển thị tiến trình thực hiện trực quan thông qua thanh tiến độ (Progress Bar) theo thời gian thực.
   - Xử lý bất đồng bộ đa luồng (multi-threading) an toàn, mượt mà và không gây đơ/treo giao diện người dùng.

4. **Tự Động Chuyển Đổi Định Dạng Word Sang PDF (`PDFConverter`)**
   - Hỗ trợ tự động chuyển đổi các tài liệu MS Word (`.doc`, `.docx`) sang định dạng `.pdf` trước khi trình ký/tải lên.
   - Sử dụng thư viện `libreconv` và tự động nhận diện đường dẫn cài đặt của **LibreOffice (soffice)** tương thích trên cả 3 hệ điều hành Windows, macOS, và Linux.

5. **Trợ Lý Trí Tuệ Nhân Tạo (AI Summarizer & Agent)**
   - **Tóm tắt văn bản thông minh (`Summarizer`):** Sử dụng mô hình `gemini-3.1-flash-lite` để tự động đọc tài liệu và trích xuất thông tin có cấu trúc như: Loại văn bản (Thông báo, Tờ trình, Báo cáo), Nội dung tóm tắt chính, và Đối tượng bị ảnh hưởng.
   - **Phân công công việc tự động (`AssignmentAgent`):** Một AI Agent chuyên biệt đóng vai trò là Lãnh đạo phòng chuyên môn cấp Phường/Xã. AI sẽ tự động đọc nội dung hồ sơ/văn bản (ví dụ: Thông báo xác nhận kết quả đăng ký đất đai), tra cứu vị trí thửa đất nằm ở **Tổ dân phố (TDP)** nào, từ đó tự động phân vai xử lý cho đúng chuyên viên địa bàn (ví dụ: Chuyên viên chính, Chuyên viên phối hợp) bằng cách kích hoạt các tool nghiệp vụ thích hợp.

---

### 🛠️ Kiến Trúc & Công Nghệ

- **Ngôn ngữ chính:** Ruby (hỗ trợ quản lý phụ thuộc bằng Bundler).
- **GUI Engine:** `glimmer-dsl-libui` (sử dụng thư viện C LibUI để vẽ giao diện native).
- **Web Automation:** Sử dụng `HTTParty` để gửi request HTTP và `Nokogiri` để phân tích cú pháp HTML/XML. Đặc biệt, hệ thống tự động xử lý các token bảo mật của ASP.NET như `__VIEWSTATE`, `__VIEWSTATEGENERATOR`, và `__EVENTVALIDATION` để vượt qua cơ chế bảo mật phiên làm việc và thực hiện đăng nhập, tải tài liệu tự động.
- **Xử lý bất đồng bộ:** `async` và `async-semaphore` giúp xử lý đồng thời (concurrency) lên đến 20 tài liệu cùng lúc mà không làm quá tải máy chủ.
- **AI Integration:** Sử dụng thư viện `ruby_llm` và `ruby_llm-schema` để tương tác trực tiếp với API của Google Gemini.

---

### 📋 Yêu Cầu Hệ Thống

1. **Ruby:** Phiên bản `>= 3.0` (Khuyên dùng quản lý qua `rvm` hoặc `rbenv`).
2. **LibreOffice:** Cần được cài đặt trên hệ thống để sử dụng tính năng chuyển đổi tài liệu sang PDF.
   - *Windows:* Mặc định tìm tại `C:\Program Files\LibreOffice\program\soffice.exe`
   - *macOS:* Mặc định tìm tại `/Applications/LibreOffice.app/Contents/MacOS/soffice`
   - *Linux:* Sử dụng lệnh `which soffice` để định vị tự động.
3. **Kết nối Internet:** Để xác thực HPNET và gọi API Gemini.

---

### ⚙️ Hướng Dẫn Cài Đặt & Cấu Hình

#### 1. Cài đặt các thư viện phụ thuộc:
```bash
bundle install
```

#### 2. Cấu hình các biến môi trường:
Sao chép file mẫu `.env.sample` thành `.env` tại thư mục gốc của dự án:
```bash
cp .env.sample .env
```
Mở file `.env` và điền đầy đủ các thông tin:
```ini
USER_NAME=tai_khoan_hpnet_cua_ban
PASSWORD=mat_khau_hpnet_cua_ban
GEMINI_API_KEY=khoa_api_gemini_cua_ban
```

---

### 🚀 Cách Sử Dụng

Khởi chạy ứng dụng bằng cách chạy file entrypoint chính:
```bash
ruby src/main.rb
```
*Lưu ý:* Nếu bạn chưa cấu hình thông tin đăng nhập trong file `.env`, ứng dụng sẽ hiển thị thông báo lỗi trên cửa sổ dòng lệnh và thoát.

---

### 🧪 Chạy Kiểm Thử (Tests)

Bộ kiểm thử của dự án sử dụng **Minitest** và được cấu hình chạy thông qua Rake. Để chạy toàn bộ test suite, thực hiện lệnh:
```bash
bundle exec rake test
```

---

### 👤 Tác Giả & Bản Quyền

- **Nhà phát triển:** Trần Bá Đạt (2026).
- Dự án được phát triển nhằm mục đích hỗ trợ tự động hóa nghiệp vụ hành chính công hiệu quả.

---

<a name="english"></a>
## 🇬🇧 ENGLISH

**HPNET Utility** is a lightweight, cross-platform desktop application built using the **Ruby** programming language and **Glimmer DSL for LibUI**. This tool automates operations on the "HPNET" administrative document management system (an ASP.NET portal in Vietnam), helping office staff and managers process administrative files and proposals much faster through robotic process automation (RPA) combined with Artificial Intelligence (AI - Gemini 3.1).

---

### 🌟 Key Features

1. **Native Graphical User Interface (GUI)**
   - Developed with **Glimmer DSL for LibUI**, delivering highly responsive, native-looking desktop windows across Windows, macOS, and Linux.
   - Extremely fast startup time and low memory footprint compared to browser-based or Electron-heavy solutions.

2. **Batch Document Submission**
   - Automatically uploads files along with summarizing metadata, then assigns them to selected leaders for review in just a few clicks.

3. **Batch Forwarding & Approval**
   - Allows users to filter and batch-approve uploaded documents by key phrases.
   - Features a real-time progress bar to visualize execution flow.
   - Built on robust multi-threading to ensure the UI remains fully responsive while document actions are processed in the background.

4. **Automated Word to PDF Conversion (`PDFConverter`)**
   - Converts Microsoft Word documents (`.doc`, `.docx`) into standard `.pdf` formats before uploading.
   - Powered by the `libreconv` gem, with dynamic self-detection of **LibreOffice (soffice)** installation paths on Windows, macOS, and Linux.

5. **AI Assistants & Agentic Workflows**
   - **Smart Summarization (`Summarizer`):** Utilizes `gemini-3.1-flash-lite` to automatically parse files and extract structured summaries: Document Type (e.g., Announcement, Proposal, Report), Abstract, and Target entities.
   - **Automated Work Allocation (`AssignmentAgent`):** A specialized AI Agent mimicking a Department Leader at a commune/ward-level government office. The AI analyzes incoming files (e.g., Land registration announcements), identifies the land plot's location to see which **Residential Group (Tổ dân phố - TDP)** it belongs to, and dynamically delegates assignments (Main Worker & Cooperative Workers) to local land-officers using appropriate business tools.

---

### 🛠️ Architecture & Technologies

- **Core Language:** Ruby (managed via Bundler).
- **GUI Engine:** `glimmer-dsl-libui` (binds directly to native C LibUI library).
- **Web Automation:** Uses `HTTParty` for HTTP request/response handling and `Nokogiri` for robust HTML/XML scraping. The system automatically scrapes and parses ASP.NET security tokens (`__VIEWSTATE`, `__VIEWSTATEGENERATOR`, and `__EVENTVALIDATION`) to preserve session state and programmatically login/upload files.
- **Asynchronous Execution:** Leverages Ruby's `async` and `async-semaphore` to safely execute concurrent background operations (up to 20 documents simultaneously) without overloading the target system.
- **AI Integration:** Implements `ruby_llm` and `ruby_llm-schema` to orchestrate structured, type-safe API requests to Google Gemini.

---

### 📋 Prerequisites

1. **Ruby:** Version `>= 3.0` (Recommended to manage via `rvm` or `rbenv`).
2. **LibreOffice:** Must be installed on your operating system for PDF conversions.
   - *Windows:* Searches under `C:\Program Files\LibreOffice\program\soffice.exe`
   - *macOS:* Searches under `/Applications/LibreOffice.app/Contents/MacOS/soffice`
   - *Linux:* Automatically resolved using the `which soffice` command.
3. **Internet Access:** Required for HPNET authentication and communicating with the Gemini API.

---

### ⚙️ Installation & Configuration

#### 1. Install dependencies:
```bash
bundle install
```

#### 2. Configure environment variables:
Copy the sample configuration file to `.env` in the project root:
```bash
cp .env.sample .env
```
Open `.env` and fill in your credentials:
```ini
USER_NAME=your_hpnet_username
PASSWORD=your_hpnet_password
GEMINI_API_KEY=your_google_gemini_api_key
```

---

### 🚀 Usage

Launch the desktop interface by executing the main script:
```bash
ruby src/main.rb
```
*Note:* If credential variables are missing from your `.env` file, the utility will print an error in the console and exit immediately.

---

### 🧪 Running Tests

The project utilizes **Minitest** for testing, which can be run through Rake tasks. To execute the entire test suite, run:
```bash
bundle exec rake test
```

---

### 👤 Author & License

- **Developer:** Tran Ba Dat (2026).
- Developed to enhance operational efficiency in administrative and public sector offices.
