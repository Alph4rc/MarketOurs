# MarketOurs

> **我们的集市，不属于任何人。**

MarketOurs 是一个面向校园社区的内容与交易平台，提供帖子、评论、关注、教师评价、通知和图片上传功能。项目包含 Web 用户端、Web 管理后台、Flutter 客户端以及 ASP.NET Core API。

## 目录

- [项目概览](#项目概览)
- [仓库结构](#仓库结构)
- [功能说明](#功能说明)
- [技术栈与版本](#技术栈与版本)
- [本地调试总览](#本地调试总览)
- [后端 API 本地调试](#后端-api-本地调试)
- [Web 本地调试](#web-本地调试)
- [Flutter 本地调试](#flutter-本地调试)
- [IP 属地功能](#ip-属地功能)
- [服务器部署](#服务器部署)
- [Docker 与外部服务](#docker-与外部服务)
- [测试、迁移与故障排查](#测试迁移与故障排查)
- [安全与隐私](#安全与隐私)
- [已知限制](#已知限制)
- [相关文档](#相关文档)

## 项目概览

### 运行组件

| 组件         | 路径                       | 作用                        |
| ---------- | ------------------------ | ------------------------- |
| **API**    | `api/MarketOurs.WebAPI/` | 认证、用户、帖子、评论、上传、通知、审核及管理接口 |
| **Web**    | `app/webapp/`            | React 用户端与管理后台（共用同一项目）    |
| **Mobile** | `app/mobile_app/`        | Flutter 跨平台移动客户端          |
| **Legal**  | `docs/legal/`            | 隐私政策与服务条款                 |

管理后台不是独立的前端工程，与用户端共用 `app/webapp`。入口为 `/admin`，由 `AdminGuard` 拦截，要求当前用户角色为 `Admin`。当前仓库暂无 `app/mini_app/` 目录，小程序尚未开发。

### 项目起源

“我实在受不了‘赞奥’的校园集市了：UI 丑、功能少、Bug 多，纯靠砸钱打下市场，体验实在太抽象了。”

这个项目我构思已久，但碍于竞品的市场壁垒，一直未敢轻易动手。直到某天晚上，王总拍着我的肩膀说：“你干就完事儿了。”

那就干吧。

## 仓库结构

```text
MarketOurs/
├── api/MarketOurs.WebAPI/
│   ├── MarketOurs.WebAPI.slnx       # .NET 解决方案文件
│   ├── MarketOurs.WebAPI/           # 启动项目（Program、控制器、中间件）
│   ├── MarketOurs.DataAPI/          # 业务服务、仓储和后台任务
│   ├── MarketOurs.Data/             # EF Core 上下文、模型、DTO 和迁移
│   └── MarketOurs.Test/             # NUnit 单元、集成、并发和压力测试
├── app/webapp/                      # React Web 用户端 + 管理后台
├── app/mobile_app/                  # Flutter 客户端
├── docs/legal/                      # 隐私政策、服务条款
├── .github/ISSUE_TEMPLATE/          # Bug 和功能建议模板
└── README.md
```

## 功能说明

### API 与用户功能

- **认证**：邮箱/手机号密码登录、验证码登录、注册、刷新令牌和注销；支持 GitHub、Google、微信等 OAuth 登录（实际可用性取决于服务商凭据配置）。
- **内容**：帖子分页列表、热门列表、搜索、标签、创建、编辑、删除、点赞、点踩和浏览量统计。
- **互动**：评论、回复、评论树、评论点赞/点踩、审核和图片支持。
- **社交与管理**：关注、公开用户资料、举报、屏蔽、通知、教师评价和用户设置。
- **文件**：图片上传 key 获取、普通上传、多图上传、流式上传和头像上传。
- **安全与运维**：AI/人工审核、敏感词过滤、速率限制、日志记录、黑名单和 Prometheus 指标暴露。

### Web 端

Web 路由涵盖首页帖子流、登录/注册、帖子详情与创建、用户资料、关注、教师评价、通知、法律页面和管理后台。Web 使用 `localStorage` 保存登录会话，并在收到 401 响应时自动尝试刷新令牌。

通知未读数采用定时轮询机制，非 WebSocket 即时推送。PWA、Service Worker 和 Web Push 代码已存在，但开发环境默认关闭 Service Worker，生产环境的离线缓存和推送仍需独立配置与验证。

### Flutter 端

Flutter 路由覆盖启动页、认证、首页/热榜、帖子创建与详情、评论、关注、通知、教师评价、用户资料、反馈及法律页面。Android、iOS、Linux、macOS 和 Windows 工程目录均已存在，但暂无 Flutter Web 工程目录。工程脚手架的存在不等于所有平台均已完成端到端验证。

### 状态标记说明

文档中的“已实现”仅表示源码中存在相应路径，不表示：

- 第三方 OAuth、邮件、短信、AI、推送或云存储已完成实际配置；
- 数据库迁移、文件上传和完整认证流程已在本机成功运行；
- 所有客户端平台和生产部署均已测试通过。

## 技术栈与版本

| 领域         | 组件与技术                                                          |
| ---------- | -------------------------------------------------------------- |
| **后端**     | ASP.NET Core / .NET 10、C#、EF Core、FluentValidation、Serilog     |
| **数据库**    | 本地默认 SQLite；设置 `SQL` 环境变量后使用 PostgreSQL + ParadeDB/`pg_search` |
| **缓存**     | Redis (`IDistributedCache`)、StackExchange.Redis、MemoryCache    |
| **认证**     | RSA JWT、OAuth2、刷新令牌机制                                          |
| **Web**    | React 19、TypeScript、React Router、Redux、Vite 8、Tailwind CSS 4   |
| **Mobile** | Flutter 3.41.9 (见 `.fvmrc`)、Dart `^3.11.0`、Dio、Riverpod        |
| **IP 解析**  | `IP2Region.Net` 3.0.1，依赖 IPv4/IPv6 `.xdb` 数据库                  |

推荐开发工具链：

- .NET SDK 10.0
- Node.js 22.13+（推荐 Node 24 LTS）
- pnpm（Web 端使用 `pnpm-lock.yaml`）
- Flutter 3.41.9 或与 `.fvmrc` 严格一致的版本
- Docker（用于集成测试、Redis 和 ParadeDB 等外部服务）

## 本地调试总览

本地联调顺序：

1. 准备 .NET、Node/pnpm、Flutter 和 Docker 工具链。
2. 准备 API 项目的 `.env`、RSA 密钥、IP2Region 数据库并启动 Redis。
3. 启动 API，观察控制台迁移日志和监听端口。
4. 调用 `/api/health` 和 `/api/metrics`，随后在浏览器检查 Scalar 文档。
5. 启动 Web，并将 `VITE_API_URL` 指向本地 API 地址。
6. （可选）修改 Flutter 本地 API 地址，连接真实设备或模拟器运行。
7. 逐步测试邮件、验证码、上传、OAuth、推送和云存储等外部集成。

API 默认开发地址为 `http://localhost:5053`，HTTPS profile 使用 `https://localhost:7242`。业务控制器路由为 `/Auth`、`/Post`、`/Comment`、`/File`、`/User` 等，不要给业务路径额外添加 `/api` 前缀。

## 后端 API 本地调试

### 1. 还原和构建

从仓库根目录执行：

```bash
dotnet restore api/MarketOurs.WebAPI/MarketOurs.WebAPI.slnx
dotnet build api/MarketOurs.WebAPI/MarketOurs.WebAPI.slnx
```

API 的启动项目目录为：`api/MarketOurs.WebAPI/MarketOurs.WebAPI/`

### 2. 准备 `.env` (注意路径)

`Program.cs` 调用 `DotNetEnv.Env.Load()`，仅读取进程工作目录下的 `.env`，不会向上或向下递归查找。对于 Web 项目，`dotnet run` 固定以项目目录作为应用工作目录。因此，`.env` 必须放在启动项目目录下：

```text
api/MarketOurs.WebAPI/MarketOurs.WebAPI/.env   ✅ 生效位置（与 Program.cs 同层）
api/MarketOurs.WebAPI/.env                     ❌ 不生效（.env.example 所在层，极易误放）
```

从仓库根目录复制模板：

```bash
# Bash / Zsh
cp api/MarketOurs.WebAPI/.env.example api/MarketOurs.WebAPI/MarketOurs.WebAPI/.env

# PowerShell
Copy-Item api\MarketOurs.WebAPI\.env.example api\MarketOurs.WebAPI\MarketOurs.WebAPI\.env
```

若同时使用 Docker Compose，`api/MarketOurs.WebAPI/.env` 是供 compose `env_file` 读取的，与本地调试那份用途不同；若保留两份，请注意同步修改。

模板已做启动容错处理（2026-10-07）：`EMAIL_PORT` 留空或缺失时回退到 564；`AI_ENDPOINT` 缺失或非法时跳过 AI 注册并打印 `[Config]` 警告，AI 审核自动降级为仅敏感词过滤，并遵守 `AI_REVIEW_FAIL_OPEN` 策略。建议按实际环境显式配置：

```dotenv
EMAIL_HOST=localhost
EMAIL_PORT=1025
EMAIL_USERNAME=mock_user
EMAIL_PASSWORD=mock_pass
EMAIL=noreply@marketours.localhost

# 可选：配置后启用 AI 审核；不配置则自动降级
AI_PROVIDER=OpenAI
AI_ENDPOINT=https://api.openai.com/v1
AI_MODEL_ID=your-model-id
AI_API_KEY=your-api-key

# 本地磁盘上传；S3/Vercel Blob 需要相应凭据
STORAGE_PROVIDER=Local

# 未配置时进程可启动，但 Session/验证码/上传 key/刷新令牌等运行期功能会失败
REDIS=localhost:6379
```

不要将真实 API key、SMTP 密码、OAuth secret 或 RSA 私钥提交到 Git。`.env.example` 中的其余变量用于 OAuth、JWT、SMTP、数据库、推送、短信、Blob、S3 和 AI 服务。

### 3. 数据库选择

- **SQLite (本地默认)**：未设置 `SQL` 时，程序配置 SQLite `Data Source=Data.db`。应用启动时会自动尝试执行待处理迁移，但迁移异常仅记录日志并继续启动；健康端点不会检查数据库是否真的可用。首次启动必须查看控制台日志，不能仅凭进程未退出判断成功。

- **PostgreSQL**：设置 `SQL` 后启用，并包含 ParadeDB 扩展配置。例如：
  
  ```dotenv
  SQL=Host=localhost;Port=5432;Database=marketours;Username=postgres;Password=change-me
  ```
  
  当前迁移包含 `pg_search`/ParadeDB 全文索引。普通 `postgres:15` 镜像不一定包含所需扩展，生产或集成测试应使用兼容的 ParadeDB 镜像并预先验证迁移。

### 4. Redis

Redis 不是可选优化：程序注册的是 Redis 分布式缓存实现，没有内存分布式缓存回退。虽然登录密码的部分路径可能不访问 Redis，但验证码、注册、刷新令牌、上传 key、部分计数和缓存功能强依赖 Redis。

本地使用 Docker 快速启动：

```bash
docker run --name marketours-redis -p 6379:6379 -d redis:alpine
```

并在 `.env` 中设置：`REDIS=localhost:6379`

### 5. IP2Region 数据库

IP 属地服务从 `AppContext.BaseDirectory` 加载：

```text
ip2region_v4.xdb
ip2region_v6.xdb
```

开发时需将文件放在：`api/MarketOurs.WebAPI/MarketOurs.WebAPI/`。`MarketOurs.WebAPI.csproj` 会自动将其复制到构建输出目录。至少应有一个可加载的地址族数据库；IPv4 和 IPv6 流量分别需要对应的数据文件。数据文件应从合法来源获取，并遵守 IP2Region 数据许可。当前仓库的二进制数据库文件不应被视为所有克隆场景都自动具备。

### 6. 生成 RSA 密钥

JWT 使用 RSA 私钥/公钥，而非对称的 `Jwt.SecretKey`。默认相对路径为：

```text
./keys/rsa_private.pem
./keys/rsa_public.pem
```

该路径相对于 API 进程工作目录。开发环境应确保启动用户可创建或读取 `keys` 目录；服务器部署时应将其放在持久化且权限受限的位置，并通过 `JWT_RSA_PRIVATE_KEY_PATH`、`JWT_RSA_PUBLIC_KEY_PATH` 指定绝对路径或正确的工作目录相对路径。

### 7. 启动和检查

从启动项目目录执行：

```bash
dotnet run --launch-profile http
```

验证接口：

```bash
curl http://localhost:5053/api/health
curl http://localhost:5053/api/metrics
```

| 地址                                           | 说明                                    |
| -------------------------------------------- | ------------------------------------- |
| `/scalar/v1`                                 | Scalar API 文档                         |
| `/api/health`                                | 默认纯文本健康状态；不检查数据库、Redis、邮件或 IP 数据库业务链路 |
| `/api/metrics`                               | Prometheus 指标                         |
| `/Auth/*`                                    | 登录、注册、验证码、刷新、注销、用户信息                  |
| `/Post/*`                                    | 帖子、搜索、热榜、评论和互动                        |
| `/Comment/*`                                 | 评论操作                                  |
| `/File/*`                                    | 上传 key、图片和头像                          |
| `/User/*`, `/Follow/*`, `/Notification/*`    | 用户、关注和通知                              |
| `/Admin/*`, `/Report/*`, `/TeacherComment/*` | 管理、举报和教师评价                            |

Scalar 映射默认存在；OpenAPI JSON 仅在 Development 环境映射。旧文档中的 `/swagger`、5000/5001 端口和 JSON 格式 `/health` 不适用于当前默认配置。

### 8. 本地创建测试账号

空数据库初始化时会自动创建开发管理员：

- **邮箱**：`adminTest@marketours.com`
- **手机号**：`101010101`
- **默认密码**：`123456`

也可通过 `USER=name,password` 覆盖初始用户的名称和密码；登录时仍使用邮箱或手机号，而非 `name` 字段。仅限本地使用默认凭据，服务器必须改为强密码。

## Web 本地调试

### 安装依赖

```bash
cd app/webapp
pnpm install --frozen-lockfile
```

当前 `package.json` 仅提供以下脚本：`pnpm dev`, `pnpm run build`, `pnpm run lint`, `pnpm run preview`。无 `test` 或 `format` 脚本。

### 配置本地 API

仓库未提供 Web `.env.example`。请手动创建 `app/webapp/.env.local`：

```dotenv
VITE_API_URL=http://localhost:5053
# 可选：VITE_VAPID_PUBLIC_KEY=your-public-vapid-key
```

注意事项：

- 变量名必须是 `VITE_API_URL`，不是 `VITE_API_BASE_URL`。
- 地址不包含 `/api`，也不要添加结尾斜杠。
- Vite 环境变量在构建时写入前端；修改 `.env.local` 后必须重启开发服务器。
- Vite 未配置 API proxy，浏览器会直接请求 API。
- 后端默认允许 `http://localhost...` 来源，若换成 `127.0.0.1`、局域网地址或自定义域名，需检查 CORS 配置。

### 启动

```bash
cd app/webapp
pnpm dev
```

默认 Vite 地址通常为 `http://localhost:5173`。首页 `/` 为帖子流，登录页为 `/login`，管理员登录后访问 `/admin`。生产构建输出目录为 `build/`，部署 BrowserRouter 时必须配置 history fallback；Vercel 配置文件位于 `app/webapp/vercel.json`。

### Web 上传链路

发帖图片通常按以下步骤完成：

1. 调用 `/File/upload/key` 获取临时 key；
2. 浏览器压缩或处理图片；
3. 调用 `/File/upload/image`、`/File/upload/images` 或流式上传接口；
4. 创建帖子时携带图片和 upload key；
5. 后端确认 key 并将文件归属到该帖子。

本地建议使用 `STORAGE_PROVIDER=Local`，文件会写入 API 的 `wwwroot/uploads`。若使用 Blob/S3，需配置对应 token、bucket、endpoint 和持久化策略。

## Flutter 本地调试

### 安装和运行

项目通过 `.fvmrc` 固定 Flutter `3.41.9`，Dart SDK 约束为 `^3.11.0`：

```bash
cd app/mobile_app
fvm flutter pub get
fvm flutter devices
fvm flutter run -d <实际设备ID>
```

若未使用 FVM，请将 `fvm flutter` 替换为 `flutter`，但应安装与 `.fvmrc` 一致的版本。请勿假定 `android` 或 `ios` 是设备 ID。

代码检查和测试：

```bash
flutter analyze
flutter test
```

模型的 `json_serializable` 生成文件已在项目中。若修改模型注解或生成文件缺失，请执行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Flutter API 地址

实际配置位于：`app/mobile_app/lib/services/api_service.dart`。
当前 `_apiBaseUrlOverride` 优先使用远程地址：`https://lumalisapi.luckyfishes.site`。这意味着备用的本地地址逻辑不会自动生效。项目不存在 `lib/config/api_config.dart`，也没有通过 `--dart-define` 配置 API 地址的实现。

本地联调时，请在本地开发分支临时将常量改为：
| 设备 | API 地址 |
| --- | --- |
| iOS 模拟器 / 桌面本机 | `http://localhost:5053` |
| Android 模拟器 | `http://10.0.2.2:5053` |
| 真机 | `http://<电脑局域网IP>:5053` |

地址不带 `/api`。`PUBLIC_WEB_BASE_URL` 仅用于分享链接的 Web 基地址，非 API 地址配置。Flutter 的上传和认证还需 API 的 Redis、存储、RSA 和数据库环境准备就绪。

### Flutter 本地网络注意事项

- Android 清单包含网络权限和明文网络设置，但真机仍需要电脑与设备网络可达。
- iOS 已针对部分本地网络场景配置例外，不能为了排错而全局开启 `NSAllowsArbitraryLoads`。
- JPush/厂商推送需要真实 AppKey、原生配置和实体设备。
- OAuth app links、应用签名和反馈 SDK 是独立的外部集成。
- IP 属地不是手机自行定位，客户端仅显示 API 返回的 `ipLocation`。

## IP 属地功能

### 功能目标

新增功能是 IP 属地显示，而非公开用户完整 IP 地址或设备 GPS 定位。系统在创建帖子或评论时，根据 HTTP 请求提取客户端 IP，并保存有限的地区文本：

- **中国 IP**：显示省份（如“北京”“广东”）；省份不可用时显示“中国”。
- **国际 IP**：显示国家（如“美国”“日本”）。
- **本地回环、私有网络、无法解析或缺少对应数据库**：显示“未知”。

数据库字段最大长度为 64 字符，后端 DTO 字段名称为 `IpLocation`，JSON 字段为 `ipLocation`。

### 后端处理流程

```text
HTTP 请求 
  -> X-Forwarded-For 
  -> X-Real-IP 
  -> x-vercel-forwarded-for 
  -> RemoteIpAddress 
  -> 判断 IPv4/IPv6 
  -> 查询对应 ip2region .xdb 
  -> 归一化为省份/国家/未知 
  -> 创建帖子或评论时写入数据库 
  -> API DTO 返回 ipLocation
```

`IpLocationService` 为 Singleton，启动时加载 `.xdb` 到内存，避免每个请求重复加载。至少需成功加载一个数据库，否则服务初始化会失败。生产环境必须只信任可信反向代理注入的转发头；当前代码会读取请求头，不能把任意公网客户端可伪造的 Header 当作可信身份来源。

帖子仓储层曾遗漏 `IpLocation` 字段（`PostRepo.CreateAsync` 的实体拷贝、`ProjectPostDtos` 和 `MapToDto` 投影），导致帖子属地只在创建响应中可见、重新查询后丢失。该问题已于 2026-10-07 修复，新帖子会正常入库并在列表、热榜和搜索结果中返回。历史帖子的属地仍为 NULL，无法回填。

### 数据库迁移

新增迁移文件：`api/MarketOurs.WebAPI/MarketOurs.Data/Migrations/20261007093028_AddIpLocationToPostAndComment.cs`  
它向 `posts` 和 `comments` 表增加可空的 `IpLocation` 字段。若当前数据库尚未应用该迁移，请从 API Web 项目目录执行：

```bash
dotnet ef database update \
  --project ../MarketOurs.Data \
  --startup-project .
```

不应在已有迁移的情况下再次生成同名迁移。迁移前应备份生产数据库，并确认目标数据库的 provider 与迁移兼容。

### 客户端显示范围

始终在作者名称旁显示；`ipLocation` 为空时渲染为“未知”（2026-10-07 起，不再隐藏整个标签）：

```text
IP属地: 北京
IP属地: 未知
```

2026-10-07 起展示位置（此前只有两端的信息流卡片）：

- **Flutter**：首页信息流卡片、帖子详情页作者区（`PostDetailHero`）、评论区（含回复）、热榜卡片、个人主页帖子卡（`SimplePostCard`）
- **Web**：信息流卡片（`PostFeed`）、帖子详情页作者区、评论区、热榜页

Flutter 端的 `post.g.dart`、`comment.g.dart` 已重新生成并包含 `ipLocation` 的解析/序列化（2026-10-07）；此前提交的生成文件缺少该字段，后续修改模型注解时仍需重新执行 `dart run build_runner build --delete-conflicting-outputs`。

### IP 功能本地验收

1. 确认至少一个 `.xdb` 位于 API 项目目录并被复制到 `bin/...` 输出目录。

2. 确认数据库已应用 `AddIpLocationToPostAndComment` 迁移。

3. 启动 API（此流程不需要 Redis；未配置时 Session 相关报错只出现在日志里，不影响本测试）。客户端为可选验证。

4. 用 `X-Forwarded-For` 请求头模拟公网 IP 创建帖子（服务端按 `X-Forwarded-For` > `X-Real-IP` > 连接地址读取）：
   
   ```bash
   curl -s -X POST http://localhost:5053/Post \
     -H "Authorization: Bearer <token>" -H "Content-Type: application/json" \
     -H "X-Forwarded-For: 220.181.38.148" \
     -d '{"title":"IP-test","content":"test","images":[],"userId":"placeholder"}'
   ```
   
   预期：创建响应 `data.ipLocation` = `"北京市"`；换成 `8.8.8.8` 显示国家；不带该头（本机）显示 `"未知"`。

5. 过审（列表只显示已过审帖子）：`PUT /Post/<id>/review`，body `{"isReview":true}`。

6. 用 `GET /Post/<id>`、`GET /Post`（列表）、`GET /Post/search` 复查 `ipLocation` 已持久化并出现在各投影中。

7. 在 Web/Flutter 客户端确认卡片、详情页、评论区、热榜显示 `IP属地: xxx`。

8. 伪造请求头仅用于本地验证；生产必须只信任可信反向代理注入的头，不要将该方法当作生产验证手段。

9. 确认隐私政策已说明 IP 属地采集和展示，再考虑生产发布。

## 服务器部署

以下是自建 Linux 服务器的部署参考流程，并非仓库内置的自动化脚本。生产环境需根据发行版、域名、反向代理、数据库和密钥管理方式灵活调整。

### 1. 准备服务器

建议准备：

- Linux 服务器和受限的应用运行用户。
- .NET 10 Runtime/SDK（构建机可使用 SDK，运行机至少需要对应 Runtime）。
- Redis。
- ParadeDB/兼容 `pg_search` 的 PostgreSQL（若使用 `SQL` 环境变量）。
- SMTP、AI、对象存储和 OAuth 服务凭据。
- 域名、TLS 证书和反向代理（Nginx/Caddy 等）。
- 持久化磁盘目录：RSA 密钥、数据库、日志、上传文件和 `.xdb`。

注意：不要将 Redis、数据库、Mailpit 或管理端口直接暴露到公网；仅暴露反向代理的 80/443 端口。

### 2. 构建发布 API

在构建机仓库根目录执行：

```bash
dotnet restore api/MarketOurs.WebAPI/MarketOurs.WebAPI.slnx
dotnet publish api/MarketOurs.WebAPI/MarketOurs.WebAPI/MarketOurs.WebAPI.csproj \
  -c Release \
  -o ./artifacts/api
```

确认发布目录包含：`MarketOurs.WebAPI.dll` 及其依赖、`ip2region_v4.xdb`/`ip2region_v6.xdb`（视实际提供情况）、必需的配置和内容文件。  
将发布文件复制到服务器，例如 `/opt/marketours/api`。不要将 `.env`、RSA 私钥、数据库密码或完整生产日志提交到代码仓库。

### 3. 配置生产环境

生产 `.env` 或 systemd EnvironmentFile 至少需要按实际环境配置：

```dotenv
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://127.0.0.1:8080

SQL=Host=127.0.0.1;Port=5432;Database=marketours;Username=marketours;Password=change-me
REDIS=127.0.0.1:6379

JWT_RSA_PRIVATE_KEY_PATH=/etc/marketours/keys/rsa_private.pem
JWT_RSA_PUBLIC_KEY_PATH=/etc/marketours/keys/rsa_public.pem
JWT_ISSUER=MarketOurs
JWT_AUDIENCE=MarketOurs

EMAIL_HOST=smtp.example.com
EMAIL_PORT=587
EMAIL_USERNAME=...
EMAIL_PASSWORD=...
EMAIL=...

STORAGE_PROVIDER=S3
S3_ACCESS_KEY=...
S3_SECRET_KEY=...
S3_BUCKET=...
S3_REGION=...
S3_ENDPOINT=https://...

AI_PROVIDER=OpenAI
AI_ENDPOINT=https://...
AI_MODEL_ID=...
AI_API_KEY=...
```

以上为变量示例，请勿原样使用。生产环境还应配置 OAuth、SMS、Firebase/JPush、Vercel Blob 或 S3 的实际变量。`USER` 仅用于空库初始化；部署前请设置强随机密码，初始化后按组织流程管理账号。

`.env` 按进程工作目录读取。运行发布产物时，systemd 必须设置正确的 `WorkingDirectory`（将 `.env` 放入该目录）或改用 `EnvironmentFile`。API 默认的 `Data.db`、`./keys`、日志和 `wwwroot/uploads` 均不能依赖易失的发布目录。

#### 持久化目录规划

生产环境至少要为以下数据准备持久化存储，并让运行用户拥有最小必要权限：

| 数据               | 默认/示例位置                 | 说明                                                                              |
| ---------------- | ----------------------- | ------------------------------------------------------------------------------- |
| **RSA 密钥**       | `/etc/marketours/keys/` | `RsaKeyManager` 会在轮换时创建 `.bak` 备份并覆盖密钥；目录必须可写且权限受限                              |
| **IP2Region 数据** | 发布目录中的 `.xdb` 文件        | 文件必须随发布产物存在；服务启动时加载到内存                                                          |
| **本地数据库**        | `Data.db`               | 仅在使用 SQLite 时使用；应放在持久化目录并定期备份                                                   |
| **本地上传**         | `wwwroot/uploads`       | `LocalStorageService` 返回 `/uploads/...` 相对 URL；跨域部署时应由反向代理映射或确认客户端补全 API origin |
| **生产日志**         | 当前工作目录下的 `logs/`        | Serilog 写入 SQLite (`log.db`) 和按日滚动文件 (`log-*.txt`)                              |

不要将密钥、上传目录、SQLite 数据库和日志放在会被发布流程覆盖的临时目录中。若使用对象存储，应改用对应 provider 并验证图片 URL、权限、CDN 和删除流程。

### 4. 应用迁移和启动

先以部署用户在临时或预生产环境验证：

```bash
cd /opt/marketours/api
dotnet MarketOurs.WebAPI.dll
```

生产使用 systemd 时，可参考以下服务单元（路径、用户和环境文件必须按服务器修改）：

```ini
[Unit]
Description=MarketOurs API
After=network-online.target redis.service
Wants=network-online.target

[Service]
Type=exec
User=marketours
WorkingDirectory=/opt/marketours/api
EnvironmentFile=/etc/marketours/marketours.env
ExecStart=/usr/bin/dotnet /opt/marketours/api/MarketOurs.WebAPI.dll
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

部署前确保 `marketours` 用户能读取 RSA 密钥和 `.xdb`，能写日志、上传目录及必要的数据保护目录，但不能写应用代码目录。启用服务后查看日志：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now marketours
sudo journalctl -u marketours -f
```

启动日志必须确认：

- AI endpoint、SMTP、Redis 和数据库没有配置异常；
- 至少一个 IP2Region 数据库加载成功；
- EF Core 迁移成功，而不是仅仅“Migration error 后继续启动”；
- API 正在监听 `127.0.0.1:8080`。

### 5. 配置反向代理和 HTTPS

以 Nginx 为例，API 只监听本机，前端和 API 可使用不同域名。配置示例：

```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate     /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;

    client_max_body_size 100m;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

生产环境必须限制谁可以直接访问 API 端口，并核对 Forwarded Headers 的可信代理边界。IP 属地依赖这些头；若代理链不可信，解析出的属地可能被伪造。HTTPS 页面访问 HTTP API 还会触发浏览器混合内容限制，Web 的 `VITE_API_URL` 应在构建时使用 HTTPS API 地址。

### 6. 发布 Web

Web 环境变量在构建阶段注入：

```bash
cd app/webapp
pnpm install --frozen-lockfile

# 创建 .env.production.local，使用真实 HTTPS API 地址
# VITE_API_URL=https://api.example.com
pnpm run lint
pnpm run build
```

将 `build/` 内容部署到 Nginx、Vercel 或其他静态托管。由于使用 BrowserRouter，必须把未知路径回退到 `index.html`。Vercel 示例配置已位于 `app/webapp/vercel.json`；部署时将项目根设置为 `app/webapp`，并确认输出目录为 `build`。  
若 Web 与 API 使用不同域名，API 的 CORS 必须允许实际 Web origin。不要将 `*` 与带凭据请求混用，也不要把带 token 的生产前端地址写死在公共文档中。

### 7. 发布 Flutter

移动端发布需按平台完成签名、商店配置、OAuth 深链、推送凭据和 API 地址处理。当前 API 地址常量优先使用远程 override，不能仅通过服务器改环境变量切换移动端后端；发布前应在专用分支确认目标 API、签名和密钥没有误提交。

建议至少执行：

```bash
cd app/mobile_app
flutter pub get
flutter analyze
flutter test
flutter build apk --release       # Android 示例，需先配置签名
flutter build ios --release       # 仅 macOS，需 Xcode/签名
```

这些命令依赖本机 Flutter、Android/iOS SDK 和平台签名配置，本 README 不声称它们在所有机器上都必然成功。

## Docker 与外部服务

`api/MarketOurs.WebAPI/compose.yaml` 包含 API、Redis、Mailpit、PostgreSQL、Prometheus 和 Grafana，但不包含 Web 或 Flutter。当前 Compose 仍应视为参考配置，存在以下局限：

- `build.dockerfile` 路径与当前 Dockerfile 位置组合不一致，需先修正或使用正确构建上下文。
- `postgres_data` 顶层 volume 声明被注释。
- `postgres:15-alpine` 不等于支持 ParadeDB/`pg_search`。
- Compose 依赖 API 目录的 `.env`，并覆盖 Redis、Mailpit 和 SQL 变量。
- Grafana 示例密码、数据库密码、JWT 密钥和上传目录不要直接用于生产。

校验 Compose 配置：

```bash
docker compose -f api/MarketOurs.WebAPI/compose.yaml config
```

在未修正上述问题并准备生产 secrets 前，不建议直接执行 `docker compose up` 作为正式部署方案。仓库中的 `Dockerfile` 使用 .NET 10 多阶段构建；若自行构建，应从与 Dockerfile 中 `COPY` 路径匹配的解决方案构建上下文执行，而非盲目照抄 Compose 的当前路径。

## 测试、迁移与故障排查

### 后端测试

```bash
# 运行所有测试
dotnet test api/MarketOurs.WebAPI/MarketOurs.WebAPI.slnx

# 运行特定测试类
dotnet test api/MarketOurs.WebAPI/MarketOurs.WebAPI.slnx \
  --filter "ClassName=PostServiceTests"
```

测试项目使用 NUnit、Moq、Testcontainers.Redis 和 Testcontainers.PostgreSql。集成测试会尝试启动 Redis 与 ParadeDB/PostgreSQL 容器；Docker 不可用时相关测试可能跳过。压力、并发和安全测试不等于生产压测结论。

### EF Core 迁移

已有 IP 属地迁移：`20261007093028_AddIpLocationToPostAndComment`

应用已有迁移：

```bash
cd api/MarketOurs.WebAPI/MarketOurs.WebAPI
dotnet ef database update \
  --project ../MarketOurs.Data \
  --startup-project .
```

模型变更后生成新迁移：

```bash
dotnet ef migrations add MigrationName \
  --project ../MarketOurs.Data \
  --startup-project .
```

不要为了 IP 属地重复生成同名迁移；生产迁移前务必备份数据库，并在与生产 provider 相同的环境中验证。

### Web 和 Flutter

```bash
cd app/webapp
pnpm run lint
pnpm run build

cd ../mobile_app
dart format .
flutter analyze
flutter test
```

Web 当前没有 `test` script 或已配置的 Vitest/Playwright 测试。Flutter 有 `test/widget_test.dart`；本次 README 修改不代表这些命令已执行并通过。

### 常见错误排查

1. **API 一启动就出现 `FormatException` 或 URI 错误**  
   `EMAIL_PORT` 空值或非法值已容错回退 564，`AI_ENDPOINT` 缺失时跳过 AI 注册并打印警告（2026-10-07）。若仍报错，请检查 `.env` 中其他数值或 URI 类变量的格式。
2. **`.env` 改了但不生效**  
   `Env.Load()` 只读取项目目录下的 `.env`（`api/MarketOurs.WebAPI/MarketOurs.WebAPI/.env`，与 `Program.cs` 同层）。最常见的错误是把它放在 `api/MarketOurs.WebAPI/`（与 `.env.example` 同层），该位置不会被读取。确认位置后重启应用。
3. **找不到 IP2Region 数据库**  
   检查两个 `.xdb` 是否位于 API 项目目录及 `bin/...` 输出目录；至少一个地址族数据库必须能够加载。确认发布时没有被清理或遗漏。
4. **健康检查正常但注册/刷新/上传失败**  
   `/api/health` 只提供基础健康响应，不检查 Redis、SMTP、AI、存储、迁移和 xdb 业务链路。请检查 API 日志、Redis 连接、SMTP 配置、`STORAGE_PROVIDER` 和数据库迁移状态。
5. **Web 返回 404 或请求错误 API**  
   检查 `.env.local` 是否使用 `VITE_API_URL` 且不含 `/api`，修改后重启 Vite。浏览器会直接请求 API，因为 Vite 没有配置代理。
6. **移动端始终连接远程 API**  
   检查 `app/mobile_app/lib/services/api_service.dart` 中的 `_apiBaseUrlOverride`。项目没有旧文档中的 `lib/config/api_config.dart`，也不能假设 `--dart-define` 会覆盖 API 地址。

## 安全与隐私

- 所有生产密码、JWT RSA 私钥、OAuth secret、SMTP/AI/存储凭据均应使用服务器 secret 管理，绝不写进 Git。
- 修改开发默认管理员密码，并严格限制管理后台访问和管理员账号权限。
- API 生产环境必须使用 HTTPS；Web 构建中的 `VITE_API_URL` 必须使用 HTTPS，以避免浏览器混合内容限制。
- Redis、数据库、Prometheus、Grafana、Mailpit 不应直接暴露于公网。
- 配置可信反向代理，严格限制 `X-Forwarded-For` 等头的可信来源；IP 属地不是安全审计证据。
- IP 属地属于基于请求 IP 的个人信息处理范围。上线前应更新 `docs/legal/privacy-policy.md`，说明采集目的、展示范围、保存策略和用户权利，并遵守适用法律及 IP2Region 数据许可。
- 本功能仅显示省份或国家等地区信息，不向前端展示完整原始 IP；本地或私网地址通常显示“未知”。

## 已知限制

1. 未配置 `REDIS` 时进程能启动，但 Session、验证码、上传 key、刷新令牌等运行期功能会失败（2026-10-07 本地实测到 Session 中间件报 `ArgumentNullException`）。完整联调应启动 Redis。
2. 迁移包含 ParadeDB/`pg_search`，普通 `postgres` 镜像不一定支持；SQLite 从零迁移已在本地实测通过（2026-10-07，23 个迁移全部应用并完成种子数据）。
3. IP 属地解析依赖 `.xdb` 文件和可信代理头；本地回环地址显示“未知”。
4. 帖子与评论的 IP 属地链路已补全（含 `PostRepo` 落库与投影修复，2026-10-07），并已完成端到端验证（创建、审核、列表、Flutter 首页卡片显示“北京市”）；但历史帖子的属地为 NULL，无法回填。
5. Web PWA 开发环境禁用 Service Worker，离线和 Push 未进行生产验收。
6. Flutter JPush、OAuth 深链、应用签名和外部反馈 SDK 需要平台级配置。
7. 当前 Web 没有自动化测试配置；Flutter 测试数量和平台覆盖不代表全平台通过。
8. Docker Compose 当前存在路径和 volume 问题，不是无需调整即可使用的生产编排方案。

## 相关文档

- [API 项目说明](api/MarketOurs.WebAPI/README.md)
- [Flutter 项目说明](app/mobile_app/README.md)
- [隐私政策](docs/legal/privacy-policy.md)
- [服务条款](docs/legal/terms-of-service.md)
- [Bug 反馈模板](.github/ISSUE_TEMPLATE/1_bug_report.yml)
- [功能建议模板](.github/ISSUE_TEMPLATE/2_feature_request.yml)
