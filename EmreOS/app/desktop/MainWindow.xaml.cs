using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Threading;
using Ellipse = System.Windows.Shapes.Ellipse;
using Line = System.Windows.Shapes.Line;

namespace AtlasDesktop;

public partial class MainWindow : Window
{
    private readonly string _vault;
    private readonly List<GraphNode> _nodes = [];
    private readonly List<WorkspaceEntry> _workspaces = [];
    private readonly List<Line> _edges = [];
    private readonly DispatcherTimer _timer;
    private double _phase;
    private GraphNode? _selected;
    private bool _atlasConversationStarted;

    public MainWindow()
    {
        InitializeComponent();
        _vault = FindVault();
        LoadWorkspaces();
        RefreshGraph();
        _timer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(40) };
        _timer.Tick += (_, _) => AnimateGraph();
        _timer.Start();
    }

    private static string FindVault()
    {
        var current = new DirectoryInfo(AppContext.BaseDirectory);
        while (current is not null) { if (File.Exists(Path.Combine(current.FullName, "AGENTS.md"))) return current.FullName; current = current.Parent; }
        return AppContext.BaseDirectory;
    }

    private void RefreshGraph()
    {
        _nodes.Clear(); _edges.Clear(); GraphCanvas.Children.Clear();
        var roots = new[] { "knowledge", "daily", "🔮 850-Companion", "memory", "nodes" }; // nodes is a legacy Atlas folder.
        var files = roots.SelectMany(folder => Directory.Exists(Path.Combine(_vault, folder)) ? Directory.EnumerateFiles(Path.Combine(_vault, folder), "*.md", SearchOption.AllDirectories) : []).Distinct().Take(600).ToList();
        foreach (var file in files)
        {
            try { _nodes.AddRange(ReadNodes(file)); } catch { }
        }
        NodeCountText.Text = $"{_nodes.Count} node • {files.Count} Markdown";
        RenderGraph();
        if (_nodes.Count > 0) SelectNode(_nodes[0]);
        else ShowEmptyState();
        SetStatus("● LOCAL GRAPH UPDATED", Brushes.MediumSpringGreen);
    }

    private IEnumerable<GraphNode> ReadNodes(string path)
    {
        var text = File.ReadAllText(path);
        var titleMatch = Regex.Match(text, @"^#\s+(.+)$", RegexOptions.Multiline);
        var title = titleMatch.Success ? titleMatch.Groups[1].Value.Trim() : Path.GetFileNameWithoutExtension(path);
        var body = Regex.Replace(text, @"(?m)^\s*#.*$|```[\s\S]*?```|\[\[([^\]]+)\]\]", " ");
        body = Regex.Replace(body, @"\s+", " ").Trim();
        var summary = string.IsNullOrWhiteSpace(body) ? "Henüz kısa özet üretilebilecek içerik yok." : body[..Math.Min(190, body.Length)] + (body.Length > 190 ? "…" : "");
        var links = Regex.Matches(text, @"\[\[([^\]|#]+)").Select(m => m.Groups[1].Value.Trim()).Where(s => s.Length > 0).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        var rel = Path.GetRelativePath(_vault, path);
        var category = rel.StartsWith("daily", StringComparison.OrdinalIgnoreCase) ? "daily" : rel.Contains("850-Companion") || rel.StartsWith("memory", StringComparison.OrdinalIgnoreCase) ? "companion" : "knowledge";
        yield return new GraphNode(title, path, rel, summary, links, category, StableHash(rel));
        // Each real section is also a concept node. This makes dense notes useful without inventing data.
        var sections = Regex.Matches(text, @"(?m)^#{2,3}\s+(.+)$").Cast<Match>().Take(16).ToList();
        for (var i = 0; i < sections.Count; i++)
        {
            var start = sections[i].Index + sections[i].Length;
            var end = i + 1 < sections.Count ? sections[i + 1].Index : text.Length;
            var sectionBody = Regex.Replace(text[start..end], @"\s+", " ").Trim();
            var sectionTitle = sections[i].Groups[1].Value.Trim();
            var sectionSummary = string.IsNullOrWhiteSpace(sectionBody) ? summary : sectionBody[..Math.Min(190, sectionBody.Length)] + (sectionBody.Length > 190 ? "…" : "");
            yield return new GraphNode(title + " · " + sectionTitle, path, rel + "  # " + sectionTitle, sectionSummary, [], category, StableHash(rel + sectionTitle));
        }
    }

    private void RenderGraph()
    {
        if (GraphCanvas.ActualWidth < 20 || GraphCanvas.ActualHeight < 20) return;
        var (cx, cy, radius) = Bounds();
        // Section headings can legitimately share a name (for example multiple "Codex" sections).
        // Wikilinks resolve to the first matching file/concept instead of crashing the desktop app.
        var targets = _nodes.GroupBy(n => NormalizeName(n.Title), StringComparer.OrdinalIgnoreCase)
            .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
        foreach (var n in _nodes)
        {
            var angle = (n.Seed % 628) / 100d;
            var cluster = n.Category == "daily" ? .72 : n.Category == "companion" ? .35 : .55;
            var distance = radius * (0.12 + ((n.Seed / 1000d) % 1) * cluster);
            n.X = cx + Math.Cos(angle) * distance; n.Y = cy + Math.Sin(angle) * distance;
        }
        foreach (var n in _nodes)
            foreach (var link in n.Links)
                if (targets.TryGetValue(NormalizeName(link), out var other) && !ReferenceEquals(n, other)) n.EdgeTargets.Add(other);
        // A short relaxation makes related files settle into a readable cluster without an expensive graph engine.
        for (var step = 0; step < 90; step++) RelaxNodes(targets, cx, cy, radius);
        foreach (var n in _nodes)
        {
            foreach (var other in n.EdgeTargets)
            {
                var edge = new Line { Stroke = new SolidColorBrush(Color.FromArgb(36, 99, 255, 174)), StrokeThickness = .7, IsHitTestVisible = false };
                GraphCanvas.Children.Add(edge); _edges.Add(edge);
            }
        }
        foreach (var n in _nodes)
        {
            var size = n.Category == "companion" ? 12 : n.Category == "daily" ? 8 : 9;
            n.Shape = new Ellipse { Width = size, Height = size, Cursor = Cursors.Hand, Stroke = new SolidColorBrush(Color.FromArgb(180, 205, 255, 230)), StrokeThickness = .7,
                Fill = new SolidColorBrush(n.Category == "daily" ? Color.FromRgb(53, 192, 118) : n.Category == "companion" ? Color.FromRgb(109, 255, 174) : Color.FromRgb(36, 229, 138)),
                Effect = new System.Windows.Media.Effects.DropShadowEffect { Color = Color.FromRgb(74, 255, 160), BlurRadius = 12, ShadowDepth = 0, Opacity = .85 } };
            n.Shape.ToolTip = new ToolTip { Content = new TextBlock { Text = n.Title + "\n" + n.Summary, Width = 280, TextWrapping = TextWrapping.Wrap, Foreground = Brushes.White }, Background = new SolidColorBrush(Color.FromRgb(5, 25, 16)), BorderBrush = Brushes.MediumSpringGreen, BorderThickness = new Thickness(1), Padding = new Thickness(10) };
            n.Shape.MouseLeftButtonDown += (_, e) => { e.Handled = true; SelectNode(n); };
            GraphCanvas.Children.Add(n.Shape);
        }
        var border = new Ellipse { Width = radius * 2, Height = radius * 2, Stroke = new SolidColorBrush(Color.FromRgb(99, 255, 174)), StrokeThickness = 1.4, IsHitTestVisible = false,
            Effect = new System.Windows.Media.Effects.DropShadowEffect { Color = Color.FromRgb(82, 255, 151), BlurRadius = 15, ShadowDepth = 0, Opacity = .9 } };
        Canvas.SetLeft(border, cx - radius); Canvas.SetTop(border, cy - radius); GraphCanvas.Children.Insert(0, border);
        DrawNodes();
    }

    private void RelaxNodes(Dictionary<string, GraphNode> targets, double cx, double cy, double radius)
    {
        foreach (var n in _nodes)
        {
            var dx = cx - n.X; var dy = cy - n.Y; n.X += dx * .001; n.Y += dy * .001;
            foreach (var other in n.EdgeTargets) { n.X += (other.X - n.X) * .003; n.Y += (other.Y - n.Y) * .003; }
        }
        for (var i = 0; i < _nodes.Count; i++) for (var j = i + 1; j < _nodes.Count; j++)
        {
            var a = _nodes[i]; var b = _nodes[j]; var dx = a.X - b.X; var dy = a.Y - b.Y; var d2 = dx * dx + dy * dy;
            if (d2 is > 0 and < 900) { var k = 1.7 / Math.Sqrt(d2); a.X += dx * k; a.Y += dy * k; b.X -= dx * k; b.Y -= dy * k; }
        }
        foreach (var n in _nodes) Clamp(n, cx, cy, radius - 10);
    }

    private void AnimateGraph()
    {
        if (_nodes.Count == 0) return; _phase += .035;
        var (cx, cy, radius) = Bounds();
        foreach (var n in _nodes) { n.X += Math.Cos(_phase + n.Seed) * .12; n.Y += Math.Sin(_phase * .83 + n.Seed) * .12; Clamp(n, cx, cy, radius - 10); }
        DrawNodes();
    }

    private void DrawNodes()
    {
        foreach (var n in _nodes) if (n.Shape is not null) { Canvas.SetLeft(n.Shape, n.X - n.Shape.Width / 2); Canvas.SetTop(n.Shape, n.Y - n.Shape.Height / 2); }
        var index = 0;
        foreach (var n in _nodes) foreach (var target in n.EdgeTargets) { if (index >= _edges.Count) return; var edge = _edges[index++]; edge.X1 = n.X; edge.Y1 = n.Y; edge.X2 = target.X; edge.Y2 = target.Y; }
    }

    private (double cx, double cy, double radius) Bounds()
    {
        var width = Math.Max(1, GraphCanvas.ActualWidth); var height = Math.Max(1, GraphCanvas.ActualHeight);
        return (width / 2, height / 2, Math.Max(90, Math.Min(width, height) / 2 - 30));
    }
    private static void Clamp(GraphNode n, double cx, double cy, double radius)
    {
        var dx = n.X - cx; var dy = n.Y - cy; var distance = Math.Sqrt(dx * dx + dy * dy);
        if (distance > radius) { n.X = cx + dx / distance * radius; n.Y = cy + dy / distance * radius; }
    }
    private static int StableHash(string value) { unchecked { var h = 23; foreach (var c in value) h = h * 31 + c; return Math.Abs(h); } }
    private static string NormalizeName(string s) => Path.GetFileNameWithoutExtension(s).Trim();

    private void SelectNode(GraphNode node)
    {
        _selected = node; ContextTitle.Text = node.Title; SummaryText.Text = node.Summary; PathText.Text = "KAYNAK  /  " + node.RelativePath;
        var backlinks = _nodes.Where(n => n.Links.Any(l => NormalizeName(l).Equals(NormalizeName(node.Title), StringComparison.OrdinalIgnoreCase))).Select(n => n.Title);
        LinksText.Text = "BAĞLANTILAR  /  " + (node.Links.Concat(backlinks).Distinct(StringComparer.OrdinalIgnoreCase).DefaultIfEmpty("yok").Aggregate((a, b) => a + "  •  " + b));
        ContentBox.Text = File.ReadAllText(node.Path).Replace("\r\n", "\n");
        SetStatus("● CONTEXT OPEN", Brushes.MediumSpringGreen);
    }
    private void ShowEmptyState() { ContextTitle.Text = "Henüz taranacak not yok"; SummaryText.Text = "knowledge/, daily/ veya 🔮 850-Companion/ içine Markdown notları ekleyin."; LinksText.Text = ""; ContentBox.Text = ""; PathText.Text = ""; }
    private void RefreshGraphClick(object sender, RoutedEventArgs e) => RefreshGraph();
    private void GraphSizeChanged(object sender, SizeChangedEventArgs e) => RefreshGraph();
    private void GraphBackgroundClick(object sender, MouseButtonEventArgs e) { if (e.OriginalSource == GraphCanvas) _selected = null; }
    private void OpenVaultClick(object sender, RoutedEventArgs e) => Process.Start(new ProcessStartInfo("explorer.exe", _vault) { UseShellExecute = true });
    private async void CompileClick(object sender, RoutedEventArgs e) => await RunAtlas("Compile");
    private async void SaveClick(object sender, RoutedEventArgs e) => await RunAtlas("Save");
    private async Task RunAtlas(string action)
    {
        SetStatus("● WORKING", Brushes.Gold);
        try { using var p = Process.Start(new ProcessStartInfo("powershell") { WorkingDirectory = _vault, Arguments = $"-ExecutionPolicy Bypass -NoProfile -File \"{Path.Combine(_vault, ".atlas", "atlas.ps1")}\" {action}", UseShellExecute = false, CreateNoWindow = true })!; await p.WaitForExitAsync(); RefreshGraph(); SetStatus("● DONE", Brushes.MediumSpringGreen); }
        catch (Exception error) { SetStatus("● ERROR", Brushes.OrangeRed); PathText.Text = error.Message; }
    }
    private async void AskAtlasClick(object sender, RoutedEventArgs e)
    {
        var question = AtlasPromptBox.Text.Trim(); if (string.IsNullOrWhiteSpace(question)) return;
        var context = _selected is null ? "Genel vault bağlamını kullan." : $"Seçili not: {_selected.RelativePath}\nÖzet: {_selected.Summary}\nİçerik:\n{ContentBox.Text[..Math.Min(5000, ContentBox.Text.Length)]}";
        var prompt = $"Sen Emre'nin Atlas yardımcısısın. Kısa, somut ve Türkçe cevap ver. Gereksiz bağlam isteme. Yalnızca ilgili notları kullan; atlas-notes MCP aracını gerektiğinde ara/oku için kullan. {context}\n\nEmre'nin sorusu: {question}\nYanıt sonunda kalıcı bilgi varsa hangi Markdown notuna kaydetmen gerektiğini belirt.";
        var requestFile = Path.Combine(Path.GetTempPath(), "atlas-opencode-" + Guid.NewGuid() + ".md");
        AtlasPromptBox.Text = ""; SetStatus("● ATLAS / OPENCODE THINKING", Brushes.Gold); ContentBox.Text = "Atlas, OpenCode ile yerel bağlam üzerinden düşünüyor…";
        try
        {
            File.WriteAllText(requestFile, prompt, Encoding.UTF8);
            var psi = new ProcessStartInfo("cmd.exe", $"/c opencode.cmd run {(_atlasConversationStarted ? "--continue " : "")}--dir \"{_vault}\" \"Atlas bağlam dosyasını yanıtla.\" --file \"{requestFile}\"")
            {
                WorkingDirectory = _vault, UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true, RedirectStandardError = true,
                StandardOutputEncoding = Encoding.UTF8, StandardErrorEncoding = Encoding.UTF8
            };
            psi.Environment["XDG_CONFIG_HOME"] = Path.Combine(_vault, ".opencode-runtime");
            using var process = Process.Start(psi)!;
            var replyTask = process.StandardOutput.ReadToEndAsync();
            var errorTask = process.StandardError.ReadToEndAsync();
            await process.WaitForExitAsync();
            var reply = await replyTask; var error = await errorTask;
            ContentBox.Text = string.IsNullOrWhiteSpace(reply) ? (string.IsNullOrWhiteSpace(error) ? "OpenCode yanıt üretemedi. OpenCode sağlayıcısını Atlas kasası için kontrol edin." : error) : reply.Trim();
            _atlasConversationStarted = process.ExitCode == 0;
            SetStatus(process.ExitCode == 0 ? "● ATLAS / OPENCODE RESPONSE READY" : "● OPENCODE ERROR", process.ExitCode == 0 ? Brushes.MediumSpringGreen : Brushes.OrangeRed);
        }
        catch (Exception error) { ContentBox.Text = error.Message; SetStatus("● OPENCODE ERROR", Brushes.OrangeRed); }
        finally { if (File.Exists(requestFile)) File.Delete(requestFile); }
    }
    private void LoadWorkspaces()
    {
        try { var saved = JsonSerializer.Deserialize<WorkspaceConfig>(File.ReadAllText(Path.Combine(_vault, "workspaces.json"))); if (saved?.Workspaces is not null) _workspaces.AddRange(saved.Workspaces); } catch { }
        WorkspaceList.ItemsSource = _workspaces; WorkspaceList.SelectedIndex = _workspaces.Count > 0 ? 0 : -1;
    }
    private void SaveWorkspaces() => File.WriteAllText(Path.Combine(_vault, "workspaces.json"), JsonSerializer.Serialize(new WorkspaceConfig { Workspaces = _workspaces }, new JsonSerializerOptions { WriteIndented = true }));
    private void WorkspaceSelectionChanged(object sender, SelectionChangedEventArgs e) { if (WorkspaceList.SelectedItem is WorkspaceEntry w) PathText.Text = "ÇALIŞMA ALANI  /  " + w.Path; }
    private void OpenCodexClick(object sender, RoutedEventArgs e)
    {
        if (WorkspaceList.SelectedItem is not WorkspaceEntry w || !Directory.Exists(w.Path)) { SetStatus("● FOLDER NOT FOUND", Brushes.OrangeRed); return; }
        Process.Start(new ProcessStartInfo("cmd.exe", $"/k set CODEX_HOME={Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".codex")}&& cd /d \"{w.Path}\" && {w.Agent}") { WorkingDirectory = w.Path, UseShellExecute = true }); SetStatus("● CODEX OPENED", Brushes.MediumSpringGreen);
    }
    private void OpenSelectedToolClick(object sender, RoutedEventArgs e)
    {
        if (WorkspaceList.SelectedItem is not WorkspaceEntry w || !Directory.Exists(w.Path)) { SetStatus("● FOLDER NOT FOUND", Brushes.OrangeRed); return; }
        var tag = (ToolList.SelectedItem as ComboBoxItem)?.Tag?.ToString() ?? "opencode";
        var config = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".codex");
        var command = tag switch
        {
            "opencode" => $"set XDG_CONFIG_HOME=\"{Path.Combine(_vault, ".opencode-runtime")}\"&& opencode.cmd \"{w.Path}\"",
            "codex" => $"set CODEX_HOME=\"{config}\"&& cd /d \"{w.Path}\"&& codex.cmd",
            "claude" => $"cd /d \"{w.Path}\"&& claude",
            "aider" => $"cd /d \"{w.Path}\"&& aider",
            "gemini" => $"cd /d \"{w.Path}\"&& gemini",
            _ => $"cd /d \"{w.Path}\"&& powershell -NoLogo"
        };
        Process.Start(new ProcessStartInfo("cmd.exe", "/k " + command) { WorkingDirectory = w.Path, UseShellExecute = true });
        SetStatus("● " + tag.ToUpperInvariant() + " OPENED", Brushes.MediumSpringGreen);
    }
    private void AddWorkspaceClick(object sender, RoutedEventArgs e)
    {
        var dialog = new AddWorkspaceWindow { Owner = this }; if (dialog.ShowDialog() != true || !Directory.Exists(dialog.WorkspacePath)) return;
        _workspaces.Add(new WorkspaceEntry { Name = dialog.WorkspaceName, Path = dialog.WorkspacePath, Agent = "codex.cmd" }); SaveWorkspaces(); WorkspaceList.Items.Refresh(); WorkspaceList.SelectedIndex = _workspaces.Count - 1;
    }
    private void SetStatus(string text, Brush color) { StatusText.Text = text; StatusText.Foreground = color; }
}

public sealed class GraphNode(string title, string path, string relativePath, string summary, List<string> links, string category, int seed)
{
    public string Title { get; } = title; public string Path { get; } = path; public string RelativePath { get; } = relativePath; public string Summary { get; } = summary; public List<string> Links { get; } = links; public string Category { get; } = category; public int Seed { get; } = seed;
    public double X { get; set; } public double Y { get; set; } public Ellipse? Shape { get; set; } public List<GraphNode> EdgeTargets { get; } = [];
}
public sealed class WorkspaceConfig { public List<WorkspaceEntry> Workspaces { get; set; } = []; }
public sealed class WorkspaceEntry { public string Name { get; set; } = ""; public string Path { get; set; } = ""; public string Agent { get; set; } = "codex.cmd"; }
public sealed class AddWorkspaceWindow : Window
{
    private readonly TextBox _name = new() { Margin = new Thickness(14, 5, 14, 8) }; private readonly TextBox _path = new() { Margin = new Thickness(14, 5, 14, 12) };
    public string WorkspaceName => _name.Text.Trim(); public string WorkspacePath => _path.Text.Trim();
    public AddWorkspaceWindow()
    {
        Title = "Atlas — çalışma alanı ekle"; Width = 460; Height = 220; ResizeMode = ResizeMode.NoResize; WindowStartupLocation = WindowStartupLocation.CenterOwner;
        var panel = new StackPanel { Background = new SolidColorBrush(Color.FromRgb(7, 20, 17)) };
        panel.Children.Add(new TextBlock { Text = "İsim", Foreground = Brushes.White, Margin = new Thickness(14, 16, 14, 0) }); panel.Children.Add(_name);
        panel.Children.Add(new TextBlock { Text = "Klasör yolu", Foreground = Brushes.White, Margin = new Thickness(14, 0, 14, 0) }); panel.Children.Add(_path);
        var actions = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Right, Margin = new Thickness(14) };
        var cancel = new Button { Content = "Vazgeç", Width = 90 }; cancel.Click += (_, _) => DialogResult = false;
        var save = new Button { Content = "Ekle", Width = 90, Margin = new Thickness(8, 0, 0, 0) }; save.Click += (_, _) => DialogResult = !string.IsNullOrWhiteSpace(WorkspaceName) && !string.IsNullOrWhiteSpace(WorkspacePath);
        actions.Children.Add(cancel); actions.Children.Add(save); panel.Children.Add(actions); Content = panel;
    }
}
