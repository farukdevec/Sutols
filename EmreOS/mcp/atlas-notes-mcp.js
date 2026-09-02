#!/usr/bin/env node
// Atlas local Markdown MCP. No network, no embeddings, no credentials.
const fs = require('fs');
const path = require('path');
const vault = process.env.ATLAS_VAULT || path.resolve(__dirname, '..');
const roots = ['knowledge', 'daily', '🔮 850-Companion', 'memory', 'nodes']; // nodes preserves the first Atlas vault's notes.

function markdownFiles() {
  const output = [];
  const walk = dir => {
    if (!fs.existsSync(dir)) return;
    for (const item of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, item.name);
      if (item.isDirectory()) walk(full);
      else if (item.isFile() && item.name.toLowerCase().endsWith('.md')) output.push(full);
    }
  };
  roots.forEach(root => walk(path.join(vault, root)));
  return output;
}
function relative(file) { return path.relative(vault, file).replace(/\\/g, '/'); }
function title(file, text) { return (text.match(/^#\s+(.+)$/m) || [])[1]?.trim() || path.basename(file, '.md'); }
function excerpt(text, max = 260) {
  const clean = text.replace(/^\s*#.*$/gm, ' ').replace(/\[\[([^\]]+)\]\]/g, '$1').replace(/\s+/g, ' ').trim();
  return clean.length > max ? clean.slice(0, max) + '…' : clean;
}
function index() { return markdownFiles().map(file => { const text = fs.readFileSync(file, 'utf8'); return { file, path: relative(file), title: title(file, text), text, modified: fs.statSync(file).mtime.toISOString() }; }); }
function result(id, value) { process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id, result: value }) + '\n'); }
function error(id, message) { process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id, error: { code: -32602, message } }) + '\n'); }
function text(value) { return { content: [{ type: 'text', text: value }] }; }

const tools = [
  { name: 'atlas_search_notes', description: 'Atlas kasasında başlık, yol ve metin üzerinden yerel Markdown ara. Önce bunu kullan; yalnızca ilgili notları oku.', inputSchema: { type: 'object', properties: { query: { type: 'string' }, limit: { type: 'integer', default: 8 } }, required: ['query'] } },
  { name: 'atlas_read_note', description: 'Atlas kasasındaki bir Markdown notunu tam olarak oku. path, atlas_search_notes sonucundan alınmalıdır.', inputSchema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  { name: 'atlas_recent_notes', description: 'Son değiştirilen Atlas Markdown notlarının kısa listesini getir.', inputSchema: { type: 'object', properties: { limit: { type: 'integer', default: 10 } } } }
];
function call(name, args) {
  const notes = index();
  if (name === 'atlas_search_notes') {
    const words = String(args.query || '').toLocaleLowerCase('tr-TR').split(/\s+/).filter(Boolean);
    const matches = notes.map(n => ({ ...n, score: words.reduce((score, w) => score + (n.title.toLocaleLowerCase('tr-TR').includes(w) ? 4 : 0) + (n.path.toLocaleLowerCase('tr-TR').includes(w) ? 2 : 0) + (n.text.toLocaleLowerCase('tr-TR').includes(w) ? 1 : 0), 0) })).filter(n => n.score > 0).sort((a, b) => b.score - a.score).slice(0, Math.min(Number(args.limit) || 8, 20));
    return text(JSON.stringify(matches.map(n => ({ path: n.path, title: n.title, summary: excerpt(n.text), modified: n.modified })), null, 2));
  }
  if (name === 'atlas_read_note') {
    const requested = String(args.path || '').replace(/\\/g, '/');
    const note = notes.find(n => n.path === requested);
    return note ? text(`# ${note.title}\n\nPath: ${note.path}\n\n${note.text}`) : text('Not bulunamadı. Önce atlas_search_notes kullan.');
  }
  if (name === 'atlas_recent_notes') {
    return text(JSON.stringify(notes.sort((a, b) => b.modified.localeCompare(a.modified)).slice(0, Math.min(Number(args.limit) || 10, 30)).map(n => ({ path: n.path, title: n.title, summary: excerpt(n.text), modified: n.modified })), null, 2));
  }
  return text('Bilinmeyen araç.');
}
let buffer = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => {
  buffer += chunk;
  let newline;
  while ((newline = buffer.indexOf('\n')) >= 0) {
    const line = buffer.slice(0, newline).trim(); buffer = buffer.slice(newline + 1); if (!line) continue;
    try {
      const request = JSON.parse(line);
      if (request.method === 'initialize') result(request.id, { protocolVersion: request.params?.protocolVersion || '2025-03-26', capabilities: { tools: {} }, serverInfo: { name: 'atlas-notes', version: '1.0.0' } });
      else if (request.method === 'notifications/initialized') { }
      else if (request.method === 'tools/list') result(request.id, { tools });
      else if (request.method === 'tools/call') result(request.id, call(request.params?.name, request.params?.arguments || {}));
      else error(request.id, 'Bilinmeyen MCP metodu.');
    } catch (e) { error(null, e.message); }
  }
});
