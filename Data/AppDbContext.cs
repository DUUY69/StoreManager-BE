using Microsoft.EntityFrameworkCore;

namespace AdminDashboard.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Supplier> Suppliers { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Store> Stores { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<OrderSupplier> OrderSuppliers { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }
    public DbSet<ReceiveImage> ReceiveImages { get; set; }
    public DbSet<StockTransaction> StockTransactions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Supplier>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Code).HasMaxLength(20);
            e.Property(x => x.Name).HasMaxLength(300);
            e.Property(x => x.Contact).HasMaxLength(50);
            e.Property(x => x.Email).HasMaxLength(100);
            e.Property(x => x.Address).HasMaxLength(500);
            e.Property(x => x.Status).HasMaxLength(20);
        });
        modelBuilder.Entity<Category>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Name).HasMaxLength(200);
            e.Property(x => x.Description).HasMaxLength(500);
        });
        modelBuilder.Entity<Store>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Code).HasMaxLength(20);
            e.Property(x => x.Name).HasMaxLength(300);
            e.Property(x => x.Address).HasMaxLength(500);
            e.Property(x => x.Phone).HasMaxLength(50);
            e.Property(x => x.Status).HasMaxLength(20);
        });
        modelBuilder.Entity<Product>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Code).HasMaxLength(30);
            e.Property(x => x.Name).HasMaxLength(300);
            e.Property(x => x.Unit).HasMaxLength(30);
            e.Property(x => x.Status).HasMaxLength(20);
        });
        modelBuilder.Entity<User>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Email).HasMaxLength(100);
            e.Property(x => x.PasswordHash).HasMaxLength(256);
            e.Property(x => x.PasswordSalt).HasMaxLength(128);
            e.Property(x => x.Name).HasMaxLength(200);
            e.Property(x => x.Phone).HasMaxLength(50);
            e.Property(x => x.Role).HasMaxLength(20);
            e.Property(x => x.Status).HasMaxLength(20);
        });
        modelBuilder.Entity<Order>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Status).HasMaxLength(30);
            e.Property(x => x.CancelReason).HasMaxLength(500);
            e.ToTable(tb => tb.UseSqlOutputClause(false)); // Bảng có thể có trigger
        });
        modelBuilder.Entity<OrderSupplier>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Status).HasMaxLength(20);
            e.Property(x => x.Note).HasMaxLength(500);
            e.Property(x => x.PaymentStatus).HasMaxLength(20);
            e.ToTable(tb => tb.UseSqlOutputClause(false)); // Bảng có trigger TR_OrderSuppliers_RecalcTotals
        });
        modelBuilder.Entity<OrderItem>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.ProductName).HasMaxLength(300);
            e.Property(x => x.Unit).HasMaxLength(30);
            e.ToTable(tb => tb.UseSqlOutputClause(false)); // Bảng có thể có trigger
        });
        modelBuilder.Entity<ReceiveImage>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Type).HasMaxLength(20);
            e.Property(x => x.ImageUrl).HasMaxLength(500);
            e.Property(x => x.FileName).HasMaxLength(255);
            e.Property(x => x.Description).HasMaxLength(500);
        });
        modelBuilder.Entity<StockTransaction>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.TransactionType).HasMaxLength(20);
            e.Property(x => x.Note).HasMaxLength(500);
        });
    }
}
