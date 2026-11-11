// Interactive STEM Infographics Widget & Science Visualizers for MakerQuest Students
import 'package:flutter/material.dart';
import '../services/sound_effects.dart';
import 'step_infographic_painter.dart';

/// Interactive Step Infographic Widget with Parts Tray, 3-Stage Progression,
/// High-Clarity Callout Drawings, and DO vs DON'T Error-Prevention Cards.
class StepInfographicWidget extends StatefulWidget {
  final String visualType;
  final String title;
  final int stepNumber;
  final String instruction;
  final String tip;

  const StepInfographicWidget({
    super.key,
    required this.visualType,
    required this.title,
    required this.stepNumber,
    required this.instruction,
    required this.tip,
  });

  @override
  State<StepInfographicWidget> createState() => _StepInfographicWidgetState();
}

class _StepInfographicWidgetState extends State<StepInfographicWidget> with SingleTickerProviderStateMixin {
  InfographicMode _currentMode = InfographicMode.blueprint;
  String? _selectedPart;
  int _activeStageIndex = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Helper: Detailed Parts & Tools Needed for this Step
  List<({String icon, String label, String qty})> _getStepParts() {
    switch (widget.visualType) {
      case 'straw_bearings':
        return [
          (icon: '🥤', label: 'Drinking Straws', qty: '2x (cut 9 cm)'),
          (icon: '📦', label: 'Chassis Base', qty: '1x (15×10 cm)'),
          (icon: '📏', label: 'Metric Ruler', qty: '1x'),
          (icon: '💧', label: 'Hot Glue Gun', qty: '1x'),
        ];
      case 'wheel_cutting':
        return [
          (icon: '📦', label: 'Rigid Cardboard', qty: '4x blanks'),
          (icon: '⭕', label: 'Circle Guide/Compass', qty: 'Ø 5.0 cm'),
          (icon: '🪵', label: 'Bamboo Skewer', qty: 'Pierce Tip'),
          (icon: '✂️', label: 'Craft Scissors', qty: '1x'),
        ];
      case 'wheel_assembly':
        return [
          (icon: '🪵', label: 'Bamboo Axles', qty: '2x (12 cm)'),
          (icon: '🍩', label: 'Donut Washers', qty: '4x spacers'),
          (icon: '⭕', label: 'Cardboard Wheels', qty: '4x discs'),
          (icon: '💧', label: 'Glue Drop', qty: 'Outer tips'),
        ];
      case 'cart_rollout':
        return [
          (icon: '🏎️', label: 'Assembled Cart', qty: '1x unit'),
          (icon: '📐', label: 'Launch Ramp', qty: '30° incline'),
          (icon: '📏', label: 'Measuring Tape', qty: '3.0 meters'),
          (icon: '🏁', label: 'Floor Runway', qty: 'Smooth surface'),
        ];
      case 'struts_cutting':
        return [
          (icon: '📦', label: 'Corrugated Cardboard Sheet', qty: '20×30 cm (0° flutes)'),
          (icon: '📏', label: 'Metric Steel Ruler', qty: '15 cm guide'),
          (icon: '✂️', label: 'Craft Scissors / Knife', qty: '1 pc'),
          (icon: '✏️', label: 'Marking Pencil', qty: '1 pc'),
        ];
      case 'hole_marking':
        return [
          (icon: '📦', label: 'Cut Cardboard Struts', qty: '6x strips (15×2 cm)'),
          (icon: '📏', label: 'Precision Ruler', qty: '1.5cm & 7.5cm marks'),
          (icon: '🎯', label: 'Hole Punch / Pushpin', qty: 'Ø 3 mm punch'),
          (icon: '✏️', label: 'Pencil for Crosshairs', qty: '1 pc'),
        ];
      case 'x_assembly':
        return [
          (icon: '📦', label: 'Punched Struts', qty: '6x strips (3 pairs)'),
          (icon: '🔩', label: 'Brass Paper Fasteners', qty: '3x center pins'),
          (icon: '🍩', label: 'Cardboard Donut Washers', qty: '3x spacers'),
        ];
      case 'lift_complete':
        return [
          (icon: '✖️', label: 'Assembled X-Units', qty: '3x linked tiers'),
          (icon: '🔩', label: 'End Pivot Split Pins', qty: '4x fasteners'),
          (icon: '📦', label: 'Base & Top Platform', qty: '2x plates'),
          (icon: '📐', label: 'Horizontal Slide Track', qty: '1x slot guide'),
        ];
      case 'axle_notch':
        return [
          (icon: '🪵', label: 'Bamboo Skewer Axle', qty: '1x (12 cm)'),
          (icon: '🔪', label: 'Craft Knife / File', qty: '0.5 mm notch'),
          (icon: '🪵', label: 'Cardboard Catch Tooth', qty: '1 pc (sliver)'),
          (icon: '💧', label: 'Wood / Hot Glue', qty: '1 drop'),
        ];
      case 'chassis_window':
        return [
          (icon: '📦', label: 'Cardboard Chassis', qty: '1x (18×8 cm)'),
          (icon: '✂️', label: 'Winding Window', qty: '4×4 cm cutout'),
          (icon: '🥤', label: 'Straw Bearings', qty: '1x 8cm, 2x 2cm'),
          (icon: '📌', label: 'Anchor Crossbar', qty: '1x pin'),
        ];
      case 'traction_tires':
        return [
          (icon: '⭕', label: 'Cardboard Wheels', qty: '4x (Ø 5.0 cm)'),
          (icon: '🛞', label: 'Wide Rubber Bands', qty: '4x traction tires'),
          (icon: '🍩', label: 'Donut Washers', qty: '4x spacers'),
          (icon: '🪵', label: 'Bamboo Axles', qty: '2x (12 cm)'),
        ];
      case 'rubber_launch':
        return [
          (icon: '🏎️', label: 'Drive Racer Unit', qty: 'Assembled'),
          (icon: '⚡', label: 'Elastic Rubber Band', qty: 'Size 64 band'),
          (icon: '📏', label: 'Runway Tape Measure', qty: '4+ meters'),
          (icon: '🏁', label: 'Smooth Floor Surface', qty: 'Test track'),
        ];
      case 'tube_cutting':
      case 'angle_testing':
      case 'banked_turns':
      case 'marble_finish':
        return [
          (icon: '🧻', label: 'Cardboard Tubes', qty: '4x rolls'),
          (icon: '⚪', label: 'Glass Marbles', qty: '2x units'),
          (icon: '🩹', label: 'Masking Tape', qty: '1x roll'),
          (icon: '📦', label: 'Support Wall', qty: '1x stand'),
        ];
      default:
        return [
          (icon: '📦', label: 'Cardboard Stock', qty: 'Required qty'),
          (icon: '📏', label: 'Ruler & Guide', qty: '1x unit'),
          (icon: '✂️', label: 'Assembly Tool', qty: '1x set'),
        ];
    }
  }

  // Helper: 3 Micro-Stages of Action
  List<({String title, String icon, String action})> _getStepStages() {
    switch (widget.visualType) {
      case 'straw_bearings':
        return [
          (title: 'Measure 9 cm', icon: '✂️', action: 'Measure two 9 cm straw segments with a ruler and trim cleanly with scissors.'),
          (title: 'Mark Guidelines', icon: '📐', action: 'Draw two parallel pencil lines 2 cm inward from the front and back chassis edges.'),
          (title: 'Glue in Place', icon: '💧', action: 'Apply an even hot glue bead along the line, press straws down firmly, and check parallel alignment.'),
        ];
      case 'wheel_cutting':
        return [
          (title: 'Trace 5cm Discs', icon: '⭕', action: 'Use a compass or circular cap to trace four identical 5 cm circles on cardboard.'),
          (title: 'Find Exact Center', icon: '🎯', action: 'Draw diagonal X crosshairs across each square blank to pinpoint the geometric center.'),
          (title: 'Pierce 3mm Hole', icon: '🪵', action: 'Carefully press the sharp skewer tip straight down through the center dot for a clean axle hole.'),
        ];
      case 'wheel_assembly':
        return [
          (title: 'Insert Axle', icon: '🪵', action: 'Thread the bamboo skewer through the straw sleeve bearing on the chassis.'),
          (title: 'Add Donut Spacer', icon: '🍩', action: 'Slide a cardboard washer onto each end, leaving a 1 mm gap from the straw edge.'),
          (title: 'Mount Wheel & Glue', icon: '🔒', action: 'Push the wheel onto the axle and apply a small glue bead at the outer tip to lock it.'),
        ];
      case 'cart_rollout':
        return [
          (title: 'Ramp Setup', icon: '📐', action: 'Prop an incline board at a 30° angle (height 30 cm) onto a smooth floor.'),
          (title: 'Hands-off Launch', icon: '🚀', action: 'Place the cart at the ramp crest and release smoothly without pushing forward.'),
          (title: 'Verify 3m Distance', icon: '🏁', action: 'Check that the cart glides at least 3 meters in a straight path with zero steering pull.'),
        ];
      case 'struts_cutting':
        return [
          (title: 'Measure 15 cm', icon: '✂️', action: 'Measure and slice 6 identical 15×2 cm cardboard strips with internal flutes parallel to length.'),
          (title: 'Check Flutes 0°', icon: '📐', action: 'Verify that corrugation flutes run lengthwise along all 6 struts for 4x higher bending resistance.'),
          (title: 'Stack & Align', icon: '📦', action: 'Stack all 6 struts and align edges flush with zero holes punched yet (holes punched in Step 2).'),
        ];
      case 'hole_marking':
        return [
          (title: 'Mark 6cm Pitch', icon: '📏', action: 'Mark 3 hole locations at 1.5 cm (left), 7.5 cm (center), and 13.5 cm (right) for exact 6.0 cm pitch.'),
          (title: 'Concentric Crosshairs', icon: '🎯', action: 'Draw perpendicular crosshairs at each mark to ensure 100% concentric alignment.'),
          (title: 'Punch 3mm Holes', icon: '🕳️', action: 'Punch crisp 3 mm pivot holes cleanly with cutout paper discs falling below.'),
        ];
      case 'x_assembly':
        return [
          (title: 'Cross 2 Struts', icon: '✖️', action: 'Intersect two 15 cm struts at their center 7.5 cm holes to form an X scissor unit.'),
          (title: 'Insert Brass Pin', icon: '🔩', action: 'Pass a brass split fastener through the center hole with a cardboard donut washer spacer in between.'),
          (title: 'Spread Flat 180°', icon: '🔄', action: 'Spread fastener legs flat 180° on back and test that the X opens and closes freely with zero bind.'),
        ];
      case 'lift_complete':
        return [
          (title: 'Join Multi-Tiers', icon: '🔗', action: 'Link 3 X-units together vertically using end brass pivot pins to build the scissor column.'),
          (title: 'Mount Sliding Base', icon: '📐', action: 'Anchor bottom left pivot to fixed base bracket and right pivot inside the horizontal sliding track.'),
          (title: 'Full Stroke Lift', icon: '🚀', action: 'Push sliding track inward to elevate top platform to full height under test load.'),
        ];
      case 'axle_notch':
        return [
          (title: 'Carve Center Notch', icon: '🔪', action: 'Mark 6.0 cm dead center on the 12 cm bamboo skewer. Carve a shallow 0.5 mm notch.'),
          (title: 'Glue Catch Tooth', icon: '🪵', action: 'Glue a tiny cardboard or toothpick sliver into the notch, slanting 60° backward.'),
          (title: 'Test Zero-Jam Slip', icon: '🔄', action: 'Hook the rubber band loop; check that it holds firmly on backward wind, but slips off cleanly on forward coasting.'),
        ];
      case 'chassis_window':
        return [
          (title: 'Mark 4×4cm Window', icon: '📐', action: 'Measure 1.5 cm from the rear edge of the 18×8 cm chassis. Draw the 4×4 cm window outline.'),
          (title: 'Cut Port Cleanly', icon: '✂️', action: 'Slice out the 4×4 cm square window with scissors or a knife to give the rubber band winding clearance.'),
          (title: 'Glue Parallel Straws', icon: '🥤', action: 'Glue the 8 cm front straw and two split 2 cm rear straws flanking the window. Mount the front anchor pin.'),
        ];
      case 'traction_tires':
        return [
          (title: 'Cut 5cm Wheel Discs', icon: '⭕', action: 'Trace and cut four identical 5.0 cm cardboard circles with concentric 3 mm center holes.'),
          (title: 'Fit Rubber Tires', icon: '🛞', action: 'Stretch wide elastic rubber bands around the perimeter rim of each wheel for maximum traction.'),
          (title: 'Mount with Spacers', icon: '🍩', action: 'Thread axles through straws, add cardboard donut spacers (1 mm gap), and glue wheels on.'),
        ];
      case 'rubber_launch':
        return [
          (title: 'Anchor & Hook Band', icon: '📌', action: 'Anchor the rubber band loop to the front crossbar and hook the rear loop over the axle tooth.'),
          (title: 'Wind Backward 6-8x', icon: '🔄', action: 'Roll the racer backward across the floor 6 to 8 turns to tightly coil the band around the rear axle.'),
          (title: 'RELEASE & Sprint 4m!', icon: '🚀', action: 'Set on floor and let go! Watch the racer sprint forward 4+ meters as the band unwinds and slips free!'),
        ];
      case 'tube_cutting':
        return [
          (title: 'Mark Centerline', icon: '📏', action: 'Draw a straight line lengthwise down the center of 4 cardboard paper rolls.'),
          (title: 'Cut U-Channel Rails', icon: '✂️', action: 'Slice tubes into halves to create open U-channel roller coaster tracks.'),
          (title: 'Smooth Track Trough', icon: '✨', action: 'Smooth track joints so marbles roll with zero friction or snagging.'),
        ];
      case 'angle_testing':
        return [
          (title: 'Prop 45° Drop', icon: '📐', action: 'Anchor first ramp segment at 45° incline to maximize initial gravitational acceleration.'),
          (title: 'Parabolic Curve', icon: '🔄', action: 'Form a gentle curved transition at track base to prevent the marble from derailing.'),
          (title: 'Timed Drop Test', icon: '⏱️', action: 'Release marble from crest and measure exit velocity at track base.'),
        ];
      case 'banked_turns':
        return [
          (title: 'Score Outer Wall', icon: '📦', action: 'Score outer edge of cardboard rail to bank the turn inward by 20°.'),
          (title: 'Support Uprights', icon: '🧱', action: 'Tape rigid upright struts behind curve to withstand lateral centrifugal thrust.'),
          (title: 'High-Speed Curve Run', icon: '🎢', action: 'Test marble at top speed to confirm centripetal force holds it inside the track.'),
        ];
      case 'marble_finish':
        return [
          (title: 'Assemble Funnel', icon: '🕳️', action: 'Build a conical deceleration catch cup at the terminal end of the track.'),
          (title: 'Coupler Joints', icon: '🏁', action: 'Connect all 4 track segments seamlessly with masking tape joints underneath.'),
          (title: 'Full Coaster Run', icon: '🏆', action: 'Release marble from summit and celebrate a flawless continuous end-to-end run!'),
        ];
      default:
        return [
          (title: 'Prepare Parts', icon: '📦', action: 'Measure and mark your raw materials according to the dimension guide.'),
          (title: 'Fabricate & Assemble', icon: '⚙️', action: 'Cut, fold, or fasten joints with precision tolerances.'),
          (title: 'Verify & Test', icon: '✅', action: 'Check movement freely by hand before moving to the next stage.'),
        ];
    }
  }

  // Helper: DO vs DON'T Error-Prevention Guidance
  ({String doTip, String dontTip}) _getDoDont() {
    switch (widget.visualType) {
      case 'straw_bearings':
        return (
          doTip: 'Ensure both straws are strictly 90° square to the chassis edges. Perfectly parallel axles guarantee straight rolling over 3+ meters!',
          dontTip: 'Avoid placing hot glue inside the straw opening. Glue droplets inside the bore will bind the axle and freeze your cart!',
        );
      case 'wheel_cutting':
        return (
          doTip: 'Spin each cut wheel on a pencil tip before mounting. It should spin smoothly like a propeller without noticeable wobble.',
          dontTip: 'Never punch the axle hole off-center! An eccentric wheel causes bumpy hopping that instantly kills rollout speed.',
        );
      case 'wheel_assembly':
        return (
          doTip: 'Leave 1 mm of side-to-side clearance between the straw and washer so the axle spins with zero friction or binding.',
          dontTip: 'Never glue the wheel disc directly to the straw bearing! Only glue the wheel to the rotating bamboo axle.',
        );
      case 'cart_rollout':
        return (
          doTip: 'Test on hard, smooth surfaces (wood, linoleum, or smooth tile) for minimum rolling resistance and true straight-line tracking.',
          dontTip: 'Avoid testing on thick carpets or textured rugs, which absorb kinetic energy and create heavy rolling drag.',
        );
      case 'struts_cutting':
        return (
          doTip: 'Cut all 6 struts (15 cm long, 2 cm wide) with internal corrugation flutes running lengthwise (0°). This provides 4× higher bending rigidity!',
          dontTip: 'Never cut struts with flutes running across the width (90°). They will instantly fold and buckle when lifting a payload.',
        );
      case 'hole_marking':
        return (
          doTip: 'Measure with surgical accuracy: 1.5 cm from left, 7.5 cm center, 1.5 cm from right (exact 6.0 cm pitch). Identical hole spacing across all 6 struts guarantees smooth scissor expansion.',
          dontTip: 'Never punch holes without crosshairs! An off-center pivot hole creates angular binding that locks the entire scissor mechanism.',
        );
      case 'x_assembly':
        return (
          doTip: 'Place a slippery washer spacer between the two struts so cardboard surfaces never grind against each other.',
          dontTip: 'Do not crimp brass split fasteners excessively tight! The pivot must swivel freely under its own weight.',
        );
      case 'lift_complete':
        return (
          doTip: 'Ensure the right-hand base pivot slides smoothly along its horizontal channel with zero sticking or side wobble.',
          dontTip: 'Never fix both bottom pivots permanently in place! A scissor lift physically requires one slider end to expand upwards.',
        );
      case 'axle_notch':
        return (
          doTip: 'Slant the catch tooth slightly backward (60°). When the rubber band unwinds fully, the loop must slip off cleanly so the car coasts forward without locking the axle!',
          dontTip: 'Never carve the notch deeper than 0.5 mm! Cutting past halfway will snap the wooden bamboo skewer under elastic winding torque.',
        );
      case 'chassis_window':
        return (
          doTip: 'Cut the 4×4 cm clearance window with clean edges. The coiled rubber band expands in diameter as it winds and needs open space to spin without snagging.',
          dontTip: 'Never mount rear straw bearings overlapping the window! The drive axle must be completely exposed in the center for direct rubber band wrapping.',
        );
      case 'traction_tires':
        return (
          doTip: 'Center the rubber band flat along the wheel rim with zero twists or bumps so the wheels grip the floor smoothly without hopping.',
          dontTip: 'Never omit the rubber tires! Bare cardboard on smooth floors has low traction (μ ≈ 0.18), causing wheels to spin out in place under elastic torque.',
        );
      case 'rubber_launch':
        return (
          doTip: 'Wind the rear wheels strictly BACKWARD. Rolling backward wraps the band in the direction that propels the racer forward upon release!',
          dontTip: 'Do not over-wind past 10 turns on your first trial! Over-stretching dry rubber bands can snap the skewer axle or snap the band.',
        );
      case 'tube_cutting':
      case 'angle_testing':
      case 'banked_turns':
      case 'marble_finish':
        return (
          doTip: 'Smooth all tape joints on the track interior so the glass marble rolls across connections with zero bounce or deceleration.',
          dontTip: 'Avoid abrupt angular bends in the track! Abrupt directional changes cause the marble to fly off the rails.',
        );
      default:
        return (
          doTip: 'Follow dimension markings carefully and test moving parts by hand to ensure smooth, unhindered operation.',
          dontTip: 'Avoid forcing joints or using excessive adhesive that could seep into rotating pivots.',
        );
    }
  }

  List<({String id, String label, String icon, String note})> _getPartCallouts() {
    switch (widget.visualType) {
      case 'straw_bearings':
        return [
          (id: 'straw', label: '9 cm Straw Sleeve', icon: '🥤', note: 'Provides an ultra-smooth cylindrical bore. Reduces axle friction by over 90% compared to raw cardboard!'),
          (id: 'chassis', label: '15×10 cm Chassis', icon: '📦', note: 'Rigid corrugated cardboard base. Cut with flutes running lengthwise for maximum bending stiffness.'),
          (id: 'glue', label: 'Hot Glue Bead', icon: '💧', note: 'Secures straw along its entire length. Keep straws strictly parallel so axles don\'t crab-walk!'),
          (id: 'parallel', label: 'Parallel Axis', icon: '↔️', note: 'Axles must be 90° square to the chassis edges for straight-line travel.'),
        ];
      case 'wheel_cutting':
        return [
          (id: 'disc', label: '5 cm Wheel Disc', icon: '⭕', note: 'Cut cleanly using a compass or circular guide. Uniform radius R prevents bumpy rolling.'),
          (id: 'center', label: 'Axle Center-Point', icon: '🎯', note: 'Find exact dead-center with diagonal crosshairs. An off-center hole causes violent bouncing!'),
          (id: 'flutes', label: 'Corrugated Grain', icon: '📐', note: 'Internal cardboard fluting provides compressive strength across the wheel face.'),
        ];
      case 'wheel_assembly':
        return [
          (id: 'axle', label: 'Bamboo Axle', icon: '🪵', note: 'Smooth 3mm wooden skewer. Spins with zero resistance inside the straw sleeve.'),
          (id: 'spacer', label: 'Donut Washer', icon: '🍩', note: 'Maintains 1mm clearance so the rotating wheel face never rubs against the cart frame.'),
          (id: 'collar', label: 'Glue Stop Collar', icon: '🔴', note: 'A tiny drop of glue at the outer axle tip locks the wheel from sliding off.'),
        ];
      case 'cart_rollout':
        return [
          (id: 'ramp', label: 'Launch Incline', icon: '📐', note: 'Converts gravitational potential energy (mgh) into forward kinetic momentum.'),
          (id: 'runway', label: '3m Target Line', icon: '🏁', note: 'Tests alignment and bearing friction over a smooth floor surface.'),
          (id: 'friction', label: 'Rolling Drag', icon: '🏎️', note: 'Wheel rotation eliminates sliding contact, keeping rolling friction coefficient low (μ = 0.02).'),
        ];
      case 'struts_cutting':
        return [
          (id: 'strut', label: '15×2 cm Struts', icon: '📦', note: 'Cut 6 identical cardboard beams (15 cm long × 2 cm wide). Equal lengths guarantee balanced vertical elevation.'),
          (id: 'flutes', label: 'Aligned Flutes (0°)', icon: '📐', note: 'Running flutes lengthwise prevents bending deflection under heavy loads.'),
          (id: 'scissors', label: 'Scissor Cut Line', icon: '✂️', note: 'Keep edges square and clean to avoid friction when linkages rotate.'),
        ];
      case 'hole_marking':
        return [
          (id: 'pitch', label: '6.0 cm Hole Pitch', icon: '📏', note: 'Holes at 1.5 cm from left, 7.5 cm center, 13.5 cm from left (6.0 cm pitch) ensure geometric symmetry.'),
          (id: 'crosshair', label: 'Center Crosshairs', icon: '🎯', note: 'Perpendicular marks ensure the hole punch centers cleanly without wandering.'),
          (id: 'hole', label: '3mm Pivot Hole', icon: '🕳️', note: 'Clean circular bore allows brass fasteners to rotate with zero drag.'),
        ];
      case 'x_assembly':
        return [
          (id: 'pin', label: 'Brass Fastener', icon: '🔩', note: 'Low-friction central axle pin connecting both struts into an X scissors unit.'),
          (id: 'spacer', label: 'Washer Spacer', icon: '⭕', note: 'Prevents cardboard faces from rubbing, eliminating mechanical friction.'),
          (id: 'swivel', label: 'Scissor Swivel', icon: '🔄', note: 'Smooth angular rotation expands and contracts the scissor mechanism effortlessly.'),
        ];
      case 'lift_complete':
        return [
          (id: 'anchor', label: 'Fixed Base Anchor', icon: '⚓', note: 'Bottom left pivot point permanently anchored to the base foundation.'),
          (id: 'slider', label: 'Horizontal Slider', icon: '↔️', note: 'Right pivot slides inward horizontally as the scissor tiers elevate upwards.'),
          (id: 'platform', label: 'Top Load Platform', icon: '📦', note: 'Stays 100% horizontal and level throughout the entire vertical stroke.'),
        ];
      case 'axle_notch':
        return [
          (id: 'axle', label: '12 cm Bamboo Axle', icon: '🪵', note: 'Smooth 3mm skewer serving as the high-torque rear drive shaft.'),
          (id: 'notch', label: '0.5 mm Center Notch', icon: '🔪', note: 'Carved at the 6.0 cm mark to securely seat the glued catch tooth.'),
          (id: 'tooth', label: 'Slanted Catch Tooth', icon: '📌', note: 'Angled at 60° backward to anchor the band on wind-up and slip free on coasting.'),
          (id: 'glue', label: 'Reinforced Glue Bead', icon: '💧', note: 'Cements the catch tooth to withstand high elastic shear forces.'),
        ];
      case 'chassis_window':
        return [
          (id: 'chassis', label: '18×8 cm Chassis', icon: '📦', note: 'Corrugated base plate cut with flutes lengthwise for zero frame sag.'),
          (id: 'window', label: '4×4 cm Winding Window', icon: '✂️', note: 'Open clearance port allowing the elastic band to coil around the axle without dragging on the floor.'),
          (id: 'straws', label: 'Split Straw Bearings', icon: '🥤', note: 'Two 2 cm straw sleeves flanking the cutout window to keep the axle straight.'),
          (id: 'anchor', label: 'Front Anchor Crossbar', icon: '📌', note: 'Rigid anchor pin where the front loop of the rubber band is secured.'),
        ];
      case 'traction_tires':
        return [
          (id: 'tires', label: 'Rubber Band Tires', icon: '🛞', note: 'Wide elastic bands stretched over wheel rims, multiplying floor grip by 5× (μ = 0.85).'),
          (id: 'wheels', label: '5.0 cm Cardboard Discs', icon: '⭕', note: 'Uniform circular wheels providing balanced rolling without hops.'),
          (id: 'washers', label: 'Donut Spacers', icon: '🍩', note: '1 mm cardboard washer clearance prevents wheels from rubbing the straw bearing ends.'),
          (id: 'collar', label: 'Outer Glue Collar', icon: '🔒', note: 'Tiny glue drop locking the wheel firmly to the spinning bamboo axle.'),
        ];
      case 'rubber_launch':
        return [
          (id: 'elastic', label: 'Elastic Rubber Band', icon: '⚡', note: 'Stores Elastic Potential Energy (Ep = ½kx²) when wound tightly around the drive axle.'),
          (id: 'torque', label: 'Axle Drive Torque', icon: '🔄', note: 'Converts elastic unwinding snap into forward rotational torque (τ = r × F).'),
          (id: 'release', label: 'Zero-Jam Release', icon: '🚀', note: 'Loop slips off the catch tooth as unwind finishes, letting the car coast freely.'),
          (id: 'runway', label: '4.0+ Meter Target', icon: '🏁', note: 'High-speed straight-line sprint rollout across smooth floors.'),
        ];
      default:
        return [
          (id: 'part1', label: 'Structural Component', icon: '📐', note: 'Precision measured and aligned for maximum strength and minimal friction.'),
          (id: 'part2', label: 'Motion Joint', icon: '⚙️', note: 'Allows mechanical degrees of freedom for kinematic linkage transmission.'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = _getStepParts();
    final stages = _getStepStages();
    final doDont = _getDoDont();
    final callouts = _getPartCallouts();

    final activeCallout = callouts.firstWhere(
      (c) => c.id == _selectedPart,
      orElse: () => callouts.first,
    );

    final currentStage = stages[_activeStageIndex.clamp(0, stages.length - 1)];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ══════════════════════════════════════════════════════════
          // 1. TOP HEADER & VIEW MODE SELECTOR
          // ══════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F9FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFBAE6FD))),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.architecture_rounded, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'STEP ${widget.stepNumber} INFOGRAPHIC BLUEPRINT',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0369A1),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                // View Mode Switcher
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildModeTab(InfographicMode.blueprint, '📐 CAD Blueprint'),
                    _buildModeTab(InfographicMode.assembly, '🎨 3D Assembly'),
                    _buildModeTab(InfographicMode.physics, '⚡ Physics Forces'),
                  ],
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // 2. 🧰 STEP PARTS & TOOLS TRAY (What to grab from table)
          // ══════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🧰', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'PARTS & TOOLS NEEDED FOR THIS STEP:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: parts.map((p) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.icon, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              p.label,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.qty,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF0369A1)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // 3. 🔄 3-STAGE PROGRESSION NAVIGATOR (A -> B -> C)
          // ══════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9)),
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(stages.length, (idx) {
                    final isCurrent = idx == _activeStageIndex;
                    final s = stages[idx];
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          SoundEffects.playPop();
                          setState(() {
                            _activeStageIndex = idx;
                          });
                          _animController.forward(from: 0.0);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: EdgeInsets.only(right: idx < stages.length - 1 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          decoration: BoxDecoration(
                            color: isCurrent ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(s.icon, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Stage ${idx + 1}: ${s.title}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                                    color: isCurrent ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                // Current Stage Directive Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app_rounded, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Stage ${_activeStageIndex + 1} Action: ${currentStage.action}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // 4. 📐 MAIN SCHEMATIC CANVAS WITH BOLD LEADER-LINE BUBBLES
          // ══════════════════════════════════════════════════════════
          Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: StepInfographicPainter(
                        visualType: widget.visualType,
                        mode: _currentMode,
                        stageIndex: _activeStageIndex,
                        highlightedPart: _selectedPart,
                        animationProgress: _animController.value,
                      ),
                    );
                  },
                ),
              ),

              // Replay / Animate Action Button (top right inside canvas)
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () {
                    SoundEffects.playPop();
                    _animController.forward(from: 0.0);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF0284C7)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 16, color: Color(0xFF0284C7)),
                        SizedBox(width: 4),
                        Text('Animate Motion', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ══════════════════════════════════════════════════════════
          // 5. 🔍 INTERACTIVE COMPONENT INSPECTOR CHIPS
          // ══════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('🔍 Inspect: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                  ...callouts.map((item) {
                    final isSelected = _selectedPart == item.id || (_selectedPart == null && item == callouts.first);
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          SoundEffects.playPop();
                          setState(() {
                            _selectedPart = item.id;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF0284C7) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(item.icon, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Active Component Note Callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFF0FDF4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔬', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.4),
                      children: [
                        TextSpan(
                          text: '${activeCallout.label}: ',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(text: activeCallout.note),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // 6. 💡 STUDENT SUCCESS CHECKLIST: DO vs DON'T (Mistake Prevention)
          // ══════════════════════════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DO (Success Key)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 11, color: Color(0xFF065F46), height: 1.4),
                            children: [
                              const TextSpan(text: 'SUCCESS KEY (DO): ', style: TextStyle(fontWeight: FontWeight.w800)),
                              TextSpan(text: doDont.doTip),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // DON'T (Pitfall to Avoid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9F1239), height: 1.4),
                            children: [
                              const TextSpan(text: 'COMMON PITFALL (DON\'T): ', style: TextStyle(fontWeight: FontWeight.w800)),
                              TextSpan(text: doDont.dontTip),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(InfographicMode mode, String label) {
    final isSelected = _currentMode == mode;
    return InkWell(
      onTap: () {
        SoundEffects.playPop();
        setState(() {
          _currentMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// 🔬 Rich STEM Science Concept Infographic Banner for Project Overview (Tab 1)
class StemConceptInfographicWidget extends StatefulWidget {
  final String projectId;
  final String conceptTitle;

  const StemConceptInfographicWidget({
    super.key,
    required this.projectId,
    required this.conceptTitle,
  });

  @override
  State<StemConceptInfographicWidget> createState() => _StemConceptInfographicWidgetState();
}

class _StemConceptInfographicWidgetState extends State<StemConceptInfographicWidget> {
  bool _showFrictionComparison = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insights_rounded, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'STEM INFOGRAPHIC: PHYSICS PRINCIPLE AT WORK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0284C7),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  SoundEffects.playPop();
                  setState(() {
                    _showFrictionComparison = !_showFrictionComparison;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _showFrictionComparison ? '🔄 Compare Modes' : '⚡ Vector View',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Render Infographic Diagram based on Project Type
          if (widget.projectId == 'proj_test_cart')
            _buildCartFrictionInfographic()
          else if (widget.projectId == 'proj_scissor_lift')
            _buildScissorLinkageInfographic()
          else if (widget.projectId == 'proj_marble_coaster')
            _buildCoasterEnergyInfographic()
          else
            _buildGenericEngineeringInfographic(),
        ],
      ),
    );
  }

  // Infographic: Sliding Friction vs Rolling Bearing Friction
  Widget _buildCartFrictionInfographic() {
    final leftCard = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        children: [
          const Text('❌ Direct Sliding Contact', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE11D48))),
          const SizedBox(height: 6),
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFB45309)),
            ),
            child: const Center(
              child: Text('Raw Cardboard on Floor\nHigh Drag μ = 0.40', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF78350F))),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Stops in 20 cm (Energy Lost to Heat)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Color(0xFF9F1239), fontWeight: FontWeight.w600)),
        ],
      ),
    );

    final rightCard = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        children: [
          const Text('✅ Straw Sleeve Bearing', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
          const SizedBox(height: 6),
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF0284C7)),
            ),
            child: const Center(
              child: Text('Rotating Wheel + Straw Bore\nRolling Drag μ = 0.02', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF0369A1))),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Rolls 300+ cm (95% Friction Eliminated!)', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: Color(0xFF166534), fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leftCard,
              const SizedBox(height: 10),
              rightCard,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: leftCard),
            const SizedBox(width: 10),
            Expanded(child: rightCard),
          ],
        );
      },
    );
  }

  Widget _buildScissorLinkageInfographic() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Text('📐', style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pantograph Mechanical Linkage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                SizedBox(height: 2),
                Text('Squeezing the horizontal base by Δx multiplies vertical platform height by N × Δy, converting lateral force into vertical lift!', style: TextStyle(fontSize: 11, color: Color(0xFF15803D))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoasterEnergyInfographic() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        children: [
          Text('⚡', style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conservation of Energy (PE ↔ KE)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                SizedBox(height: 2),
                Text('High Drop Height = Maximum Gravitational PE (mgh). As marble descends, PE transforms into Kinetic Velocity (½mv²)!', style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericEngineeringInfographic() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Text('⚙️', style: TextStyle(fontSize: 24)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Iterative STEM Engineering Process', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF334155))),
                SizedBox(height: 2),
                Text('Design → Prototype → Test → Diagnose Failure Points → Iterate with Improved Tolerance and Rigid Structural Geometry.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
