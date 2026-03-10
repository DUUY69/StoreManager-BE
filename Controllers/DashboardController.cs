using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize]
public class DashboardController : ControllerBase
{
    /// <summary>Số liệu dashboard (tổng đơn, đang giao, đơn gần đây).</summary>
    [HttpGet("stats")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult Stats([FromQuery] string? dateFrom, [FromQuery] string? dateTo)
    {
        var result = new
        {
            totalOrders = 20,
            deliveringCount = 3,
            lateCount = 1,
            recentOrders = new[]
            {
                new { id = 1, storeName = "Cafe Q1", orderDate = "2025-03-01", status = "Accepted" }
            }
        };
        return Ok(result);
    }
}
