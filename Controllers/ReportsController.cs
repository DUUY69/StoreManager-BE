using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/reports")]
[Authorize]
public class ReportsController : ControllerBase
{
    /// <summary>Báo cáo tổng hợp theo NCC và cửa hàng. Query: dateFrom, dateTo.</summary>
    [HttpGet("summary")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult Summary([FromQuery] string? dateFrom, [FromQuery] string? dateTo)
    {
        var result = new
        {
            totalOrders = 15,
            totalOrderSuppliers = 28,
            completedOrderSuppliers = 20,
            bySupplier = new[] { new { id = 1, name = "Trung Nguyên", totalOrders = 8, completed = 6, totalItems = 120 } },
            byStore = new[] { new { id = 1, name = "Cafe Q1", totalOrders = 10 } }
        };
        return Ok(result);
    }
}
