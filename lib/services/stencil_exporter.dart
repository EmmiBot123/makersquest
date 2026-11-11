// Printable A4 1:1 Cardboard Stencil SVG Generator & Exporter
import 'stencil_exporter_stub.dart'
    if (dart.library.js_interop) 'stencil_exporter_web.dart';

class StencilExporter {
  static const String sampleFilename = 'makerquest-free-scissor-stencil.svg';

  /// Last generated filename during tests/runtime inspection.
  static String? lastDownloadedFilename;

  /// Generates a dimensionally accurate A4 (210mm x 297mm) printable SVG template
  /// for building a real cardboard Scissor Grabber using household delivery boxes.
  static String buildScissorGrabberStencilSvg() {
    final buf = StringBuffer();
    buf.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="210mm" height="297mm" viewBox="0 0 210 297">',
    );
    buf.writeln('  <defs>');
    buf.writeln(
      '    <pattern id="grid5mm" width="5" height="5" patternUnits="userSpaceOnUse">',
    );
    buf.writeln(
      '      <path d="M 5 0 L 0 0 0 5" fill="none" stroke="#e2e8f0" stroke-width="0.25"/>',
    );
    buf.writeln('    </pattern>');
    buf.writeln('  </defs>');
    buf.writeln('  <rect x="0" y="0" width="210" height="297" fill="#ffffff"/>');
    buf.writeln('  <rect x="10" y="10" width="190" height="277" fill="url(#grid5mm)" stroke="#cbd5e1" stroke-width="0.5"/>');
    buf.writeln(
      '  <text x="16" y="21" font-family="Arial, sans-serif" font-size="6" font-weight="bold" fill="#0f172a">MAKERQUEST • FREE A4 PRINTABLE STENCIL (PROJECT #1: SCISSOR GRABBER)</text>',
    );
    buf.writeln(
      '  <text x="16" y="27" font-family="Arial, sans-serif" font-size="3.6" fill="#475569">Print at 100% Scale -> Glue onto Amazon/Flipkart box -> Align flutes with arrows -> Cut dashed lines!</text>',
    );
    // 5 cm Calibration Ruler
    buf.writeln('  <rect x="16" y="32" width="50" height="6" fill="#fef3c7" stroke="#f59e0b" stroke-width="0.4"/>');
    buf.writeln('  <line x1="16" y1="38" x2="66" y2="38" stroke="#0f172a" stroke-width="0.6"/>');
    for (int cm = 0; cm <= 5; cm++) {
      final x = 16 + cm * 10;
      buf.writeln('  <line x1="$x" y1="35" x2="$x" y2="38" stroke="#0f172a" stroke-width="0.5"/>');
      buf.writeln('  <text x="${x - 1}" y="34.5" font-family="Arial" font-size="2.5" fill="#0f172a">$cm</text>');
    }
    buf.writeln('  <text x="70" y="36.8" font-family="Arial, sans-serif" font-size="3.2" font-weight="bold" fill="#b45309">Calibration Check: Should measure 5.0 cm (50 mm)</text>');

    // 4 identical 150mm x 20mm Scissor Linkage Struts
    for (int i = 0; i < 4; i++) {
      final y = 46 + i * 26;
      buf.writeln(
        '  <rect x="18" y="$y" width="150" height="20" rx="5" fill="#fefce8" stroke="#d97706" stroke-width="0.6" stroke-dasharray="3,1.5"/>',
      );
      buf.writeln(
        '  <text x="93" y="${y + 8.5}" text-anchor="middle" font-family="Arial, sans-serif" font-size="3.5" font-weight="bold" fill="#78350f">LINKAGE STRUT #${i + 1} (15 cm x 2 cm) • === FLUTE GRAIN ===&gt;</text>',
      );
      for (final hx in [28, 93, 158]) {
        buf.writeln('  <circle cx="$hx" cy="${y + 10}" r="2" fill="#ffffff" stroke="#0f172a" stroke-width="0.5"/>');
        buf.writeln('  <circle cx="$hx" cy="${y + 10}" r="0.4" fill="#ef4444"/>');
      }
      buf.writeln(
        '  <text x="93" y="${y + 16.5}" text-anchor="middle" font-family="Arial" font-size="2.6" fill="#64748b">Poke 4mm bamboo skewer / straw holes at circles</text>',
      );
    }

    // 2 Jaw ClawTips
    for (int j = 0; j < 2; j++) {
      final x = 18 + j * 92;
      const y = 156;
      buf.writeln(
        '  <path d="M $x $y L ${x + 82} $y L ${x + 82} ${y + 16} L ${x + 56} ${y + 26} L $x ${y + 24} Z" fill="#ecfeff" stroke="#0284c7" stroke-width="0.6" stroke-dasharray="3,1.5"/>',
      );
      buf.writeln(
        '  <text x="${x + 41}" y="${y + 12}" text-anchor="middle" font-family="Arial" font-size="3.4" font-weight="bold" fill="#0369a1">CLAW JAW #${j + 1} (Wrap rubber band on tip!)</text>',
      );
      buf.writeln('  <circle cx="${x + 12}" cy="${y + 12}" r="2" fill="#ffffff" stroke="#0f172a" stroke-width="0.5"/>');
      buf.writeln('  <circle cx="${x + 38}" cy="${y + 12}" r="2" fill="#ffffff" stroke="#0f172a" stroke-width="0.5"/>');
    }

    // Trigger Slider Handle
    buf.writeln(
      '  <rect x="18" y="194" width="120" height="32" rx="6" fill="#f0fdf4" stroke="#16a34a" stroke-width="0.6" stroke-dasharray="3,1.5"/>',
    );
    buf.writeln(
      '  <line x1="18" y1="210" x2="138" y2="210" stroke="#15803d" stroke-width="0.4" stroke-dasharray="1.5,1.5"/>',
    );
    buf.writeln(
      '  <text x="78" y="205" text-anchor="middle" font-family="Arial" font-size="3.6" font-weight="bold" fill="#166534">SLIDE GRIP HANDLE (Score center dashed line &amp; fold)</text>',
    );
    buf.writeln('  <circle cx="32" cy="218" r="2" fill="#ffffff" stroke="#0f172a" stroke-width="0.5"/>');
    buf.writeln('  <circle cx="124" cy="218" r="2" fill="#ffffff" stroke="#0f172a" stroke-width="0.5"/>');

    // Quick Build Guide Footer
    buf.writeln('  <rect x="16" y="238" width="178" height="38" rx="4" fill="#f8fafc" stroke="#94a3b8" stroke-width="0.4"/>');
    buf.writeln('  <text x="22" y="246" font-family="Arial" font-size="3.8" font-weight="bold" fill="#0f172a">3-Step Build Recipe (Zero Plastic Kit Needed):</text>');
    buf.writeln('  <text x="22" y="253" font-family="Arial" font-size="3.2" fill="#334155">1. Cut all 4 struts + 2 jaws + handle cleanly along outer dashed lines.</text>');
    buf.writeln('  <text x="22" y="259" font-family="Arial" font-size="3.2" fill="#334155">2. Stack pairs in X-shapes and pin center &amp; ends with toothpicks + 5mm straw collars.</text>');
    buf.writeln('  <text x="22" y="265" font-family="Arial" font-size="3.2" fill="#334155">3. Attach rubber bands around jaw tips for 250g grip friction. Squeeze handle to reach!</text>');
    buf.writeln('  <text x="22" y="272" font-family="Arial" font-size="3.0" font-weight="bold" fill="#4f46e5">Unlock all 17 blueprints &amp; 3D assembly sims at emmibot123.github.io/makersquest • WhatsApp +918075971988</text>');
    buf.writeln('</svg>');
    return buf.toString();
  }

  static bool downloadScissorStencil() {
    lastDownloadedFilename = sampleFilename;
    return downloadTextFileImpl(
      sampleFilename,
      'image/svg+xml;charset=utf-8',
      buildScissorGrabberStencilSvg(),
    );
  }
}
