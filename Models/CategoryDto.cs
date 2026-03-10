namespace AdminDashboard.Api.Models;

public class CategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = "";
    public string? Description { get; set; }
}

public class CategoryCreateUpdateDto
{
    public string Name { get; set; } = "";
    public string? Description { get; set; }
}
