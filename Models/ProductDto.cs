namespace AdminDashboard.Api.Models;

public class ProductDto
{
    public int Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public int SupplierId { get; set; }
    public int CategoryId { get; set; }
    public string Unit { get; set; } = "cái";
    public decimal Price { get; set; }
    public string Status { get; set; } = "Active";
}

public class ProductCreateUpdateDto
{
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public int SupplierId { get; set; }
    public int CategoryId { get; set; }
    public string Unit { get; set; } = "cái";
    public decimal Price { get; set; }
    public string Status { get; set; } = "Active";
}
