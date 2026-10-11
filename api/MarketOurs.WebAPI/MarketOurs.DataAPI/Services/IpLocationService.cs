using IP2Region.Net.Abstractions;
using IP2Region.Net.XDB;
using Microsoft.AspNetCore.Http;
using System.Net;
using System.Net.Sockets;

namespace MarketOurs.DataAPI.Services;

/// <summary>
/// IP 属地解析服务接口
/// </summary>
public interface IIpLocationService
{
    /// <summary>
    /// 获取客户端 IP 和对应的地理位置
    /// </summary>
    /// <param name="context">HTTP 上下文</param>
    /// <param name="ip">输出参数：客户端 IP 地址</param>
    /// <returns>地理位置描述（省份或国家），无法解析时返回"未知"</returns>
    string GetClientIpAndLocation(HttpContext context, out string? ip);
}

/// <summary>
/// IP 属地解析服务实现（支持 IPv4 + IPv6 双栈）
/// </summary>
public class IpLocationService : IIpLocationService, IDisposable
{
    private readonly ISearcher? _v4Searcher;
    private readonly ISearcher? _v6Searcher;
    private bool _disposed;

    public IpLocationService()
    {
        var basePath = AppContext.BaseDirectory;
        var v4Path = Path.Combine(basePath, "ip2region_v4.xdb");
        var v6Path = Path.Combine(basePath, "ip2region_v6.xdb");

        // 初始化 IPv4 搜索器
        if (File.Exists(v4Path))
        {
            try
            {
                _v4Searcher = new Searcher(CachePolicy.Content, v4Path);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to load IPv4 database: {ex.Message}");
            }
        }

        // 初始化 IPv6 搜索器
        if (File.Exists(v6Path))
        {
            try
            {
                _v6Searcher = new Searcher(CachePolicy.Content, v6Path);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to load IPv6 database: {ex.Message}");
            }
        }

        if (_v4Searcher == null && _v6Searcher == null)
        {
            throw new FileNotFoundException(
                $"IP2Region database files not found. Please ensure ip2region_v4.xdb and/or ip2region_v6.xdb exist in: {basePath}");
        }
    }

    /// <inheritdoc/>
    public string GetClientIpAndLocation(HttpContext context, out string? ip)
    {
        ip = GetRealClientIp(context);

        // 处理本地或内网 IP
        if (string.IsNullOrWhiteSpace(ip) || IsLocalOrPrivateIp(ip))
        {
            return "未知";
        }

        try
        {
            string? region = null;

            // 解析 IP 并判断是 IPv6 还是 IPv4
            if (IPAddress.TryParse(ip, out var ipAddress))
            {
                if (ipAddress.AddressFamily == AddressFamily.InterNetworkV6)
                {
                    // IPv6：使用 v6 搜索器
                    if (_v6Searcher != null)
                    {
                        region = _v6Searcher.Search(ip);
                    }
                }
                else if (ipAddress.AddressFamily == AddressFamily.InterNetwork)
                {
                    // IPv4：使用 v4 搜索器
                    if (_v4Searcher != null)
                    {
                        region = _v4Searcher.Search(ip);
                    }
                }
            }

            return ParseRegion(region);
        }
        catch (Exception)
        {
            // IP 解析失败时返回"未知"
            return "未知";
        }
    }

    /// <summary>
    /// 解析 IP2Region 返回的区域字符串
    /// </summary>
    private static string ParseRegion(string? region)
    {
        if (string.IsNullOrWhiteSpace(region))
        {
            return "未知";
        }

        // IP2Region 格式: 国家|区域|省份|城市|ISP
        // 示例: 中国|0|北京|北京市|电信
        var parts = region.Split('|');

        if (parts.Length < 3)
        {
            return "未知";
        }

        var country = parts[0];
        var province = parts[2];

        // 中国 IP：返回省份（如果省份是 0 则返回"中国"）
        if (country == "中国")
        {
            return string.IsNullOrEmpty(province) || province == "0" ? "中国" : province;
        }

        // 其他国家：返回国家名
        return string.IsNullOrEmpty(country) || country == "0" ? "未知" : country;
    }

    /// <summary>
    /// 从 HTTP 请求头中提取真实客户端 IP
    /// 优先级：X-Forwarded-For > X-Real-IP > x-vercel-forwarded-for > RemoteIpAddress
    /// </summary>
    private static string? GetRealClientIp(HttpContext context)
    {
        // 优先读取反向代理/CDN 转发的真实 IP
        var headers = new[] { "X-Forwarded-For", "X-Real-IP", "x-vercel-forwarded-for" };

        foreach (var header in headers)
        {
            var headerValue = context.Request.Headers[header].FirstOrDefault();
            if (!string.IsNullOrWhiteSpace(headerValue))
            {
                // X-Forwarded-For 可能包含多个 IP（客户端 IP, 代理1 IP, 代理2 IP）
                // 取第一个 IP 作为真实客户端 IP
                return headerValue.Split(',')[0].Trim();
            }
        }

        // 如果没有代理头，直接使用连接的远程 IP
        return context.Connection.RemoteIpAddress?.ToString();
    }

    /// <summary>
    /// 判断是否为本地或内网 IP
    /// </summary>
    private static bool IsLocalOrPrivateIp(string ip)
    {
        // 本地回环地址
        if (ip == "::1" || ip == "127.0.0.1")
        {
            return true;
        }

        // 内网地址
        if (ip.StartsWith("192.168.") || ip.StartsWith("10."))
        {
            return true;
        }

        // 172.16.0.0 - 172.31.255.255
        if (ip.StartsWith("172."))
        {
            var parts = ip.Split('.');
            if (parts.Length > 1 && int.TryParse(parts[1], out int secondOctet))
            {
                if (secondOctet >= 16 && secondOctet <= 31)
                {
                    return true;
                }
            }
        }

        return false;
    }

    public void Dispose()
    {
        if (_disposed) return;

        _v4Searcher?.Dispose();
        _v6Searcher?.Dispose();
        _disposed = true;
        GC.SuppressFinalize(this);
    }
}
