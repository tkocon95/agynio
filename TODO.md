# TODO: Fix Thread nodeId Type Mismatch

## Vấn đề
Khi tạo thread qua API, bị lỗi "Failed to create the thread. Please retry."

### Root Cause
- `assigned_agent_node_id` và `channel_node_id` trong Thread table được định nghĩa là `@db.Uuid`
- Nhưng nodeId thực tế là string như `"agent-i4tnppb9"`, không phải UUID
- Prisma không thể insert string vào cột UUID

## Đã làm
1. ✅ Sửa schema: Đổi từ `@db.Uuid` → `String` trong `schema.prisma`
2. ✅ Tạo migration file `20260214000001_fix_nodeid_type/migration.sql`
3. ✅ Commit code lên git (branch dev)

## Cần làm

### 1. Docker Context Issue (ĐANG BỊ BLOCK)
Docker container `migrate` không mount được migration file mới
```
Ls /prisma/migrations/ # Không thấy file 20260214000001_fix_nodeid_type/
```
**Có thể do:**
- Docker context không access volume đúng
- Image được build từ source khác

### 2. Kiểm tra xác nhận
```bash
# Xem migration file có trong container không
docker compose run --rm migrate ls /prisma/migrations/

# Hoặc kiểm tra trực tiếp trong container
docker exec -it migrate ls /prisma/migrations/
```

### 3. Nếu file không tồn tại trong container
Cần rebuild Docker image/context để mount đúng volume

### 4. Verify sau khi fix
```bash
# Kiểm tra schema đã đổi chưa
docker exec agents-db psql -U agents -d agents -c '\d "Thread"' | grep -E "channel_node_id|assigned_agent"
# Kết quả mong đợi: text (không phải uuid)
```

## Commands hữu ích
```bash
# Restart services
docker compose down && docker compose up -d

# Check migration logs  
docker compose logs migrate

# Check Thread table schema
docker exec agents-db psql -U agents -d agents -c '\d "Thread"'
```

## Liên quan
- File: `packages/platform-server/prisma/schema.prisma`
- Migration: `packages/platform-server/prisma/migrations/20260214000001_fix_nodeid_type/migration.sql`
- Branch: `dev` (đã commit)
