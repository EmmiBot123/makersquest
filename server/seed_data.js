// MakerQuest Seed Data: Badges, Projects, Checkpoint Challenges, and Demo Users
// Enriched with Authentic STEM Mechanisms from "Cardboard Robotics: Simple Mechanisms that Really Work"

const BADGES = [
  {
    id: "badge_first_spark",
    title: "First Spark",
    description: "Welcome to MakerQuest! Created your student workshop account.",
    icon: "⚡",
    category: "Milestone",
    xp_bonus: 50
  },
  {
    id: "badge_cardboard_pioneer",
    title: "Cardboard Pioneer",
    description: "Mastered Level 1: Cardboard Mechanics & structural stability.",
    icon: "📦",
    category: "Level",
    xp_bonus: 100
  },
  {
    id: "badge_material_collector",
    title: "Resourceful Gatherer",
    description: "Gathered 100% of materials for your DIY engineering build.",
    icon: "🧰",
    category: "Skill",
    xp_bonus: 50
  },
  {
    id: "badge_kinetic_king",
    title: "Kinetic Master",
    description: "Conquered Level 2: Simple Machines, Pulleys & Mechanical Advantage.",
    icon: "⚙️",
    category: "Level",
    xp_bonus: 150
  },
  {
    id: "badge_circuit_spark",
    title: "Circuit Luminary",
    description: "Built working electronic circuits and conquered Level 3.",
    icon: "💡",
    category: "Level",
    xp_bonus: 200
  },
  {
    id: "badge_troubleshooter_ace",
    title: "Troubleshooter Ace",
    description: "Achieved a perfect score on a Maker Checkpoint Challenge.",
    icon: "🎯",
    category: "Skill",
    xp_bonus: 100
  },
  {
    id: "badge_bot_whisperer",
    title: "Bot Whisperer",
    description: "Built your first mobile vibration robot (Wiggle-Bot).",
    icon: "🤖",
    category: "Skill",
    xp_bonus: 120
  },
  {
    id: "badge_solar_architect",
    title: "Solar Architect",
    description: "Constructed an eco-friendly solar-powered sunflower tracker.",
    icon: "🌻",
    category: "Skill",
    xp_bonus: 250
  },
  {
    id: "badge_mechanism_maestro",
    title: "Mechanism Maestro",
    description: "Mastered authentic sleeve bearings, linkages & cams from Cardboard Robotics.",
    icon: "🦾",
    category: "Skill",
    xp_bonus: 160
  },
  {
    id: "badge_master_cadet",
    title: "Master Maker Summit",
    description: "Constructed the Autonomous Rescue Rover and completed the STEM Capstone.",
    icon: "🏆",
    category: "Milestone",
    xp_bonus: 350
  }
];

const PROJECTS = [
  // ══════════════════════════════════════════════════════════════════
  // LEVEL 1: Cardboard Mechanics & Foundational Linkages (Ch. 1-3)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "proj_scissor_lift",
    level_required: 1,
    title: "Cardboard Scissor Lift Mechanism",
    description: "Engineer an expanding pantograph scissor lift using cardboard struts, hole spacing, and brass fasteners. Learn how cross-linkages transform small horizontal pushes into high vertical reaches!",
    category: "Cardboard Mechanics",
    difficulty: "Beginner",
    estimated_time: "35 mins",
    xp_reward: 120,
    badge_reward: "badge_material_collector",
    order_index: 1,
    materials_list: [
      { id: "m1", name: "Heavy corrugated cardboard sheet (approx. 20x30 cm)", amount: "1 sheet", optional: false, tip: "Recycled cereal or shipping boxes work fantastic! Cut with flutes running lengthwise." },
      { id: "m2", name: "Split pins / Brass paper fasteners", amount: "12 pcs", optional: false, tip: "Paper fasteners allow joints to pivot freely. Add cardboard washers!" },
      { id: "m3", name: "Wooden skewers or bamboo chopsticks", amount: "2 pcs", optional: false, tip: "Used as crossbar stabilizers between scissor arms." },
      { id: "m4", name: "Rubber bands", amount: "3 pcs", optional: true, tip: "Provides spring-back tension for quick resets." },
      { id: "m5", name: "Ruler & Pencil", amount: "1 each", optional: false, tip: "Accurate hole spacing ensures smooth movement." },
      { id: "m6", name: "Kid-safe craft scissors or hole punch", amount: "1 pc", optional: false, tip: "Make clean pivot holes without tearing the cardboard." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Measure & Cut Cardboard Struts with Aligned Flutes",
        instruction: "Use a ruler to draw six identical cardboard strips, each 15 cm long and 2 cm wide. Cut them so internal corrugation flutes run along the length for maximum bending resistance.",
        tip: "Line up all six strips together and sand or trim edges so they match identically.",
        safety_note: "Always cut away from your body and keep fingers clear of scissor blades.",
        visual_type: "struts_cutting"
      },
      {
        step_number: 2,
        title: "Mark & Punch Precision Pivot Holes",
        instruction: "On each strip, mark 3 hole positions: one at 1.5 cm from the left, one at the center (7.5 cm), and one at 1.5 cm from the right. Punch neat, small holes at all markings.",
        tip: "Use the tip of a pencil or pushpin over scrap cardboard to punch clean holes.",
        safety_note: "Do not poke holes with your hands directly behind the cardboard.",
        visual_type: "hole_marking"
      },
      {
        step_number: 3,
        title: "Assemble the X-Links with Cardboard Spacer Washers",
        instruction: "Cross two cardboard strips in an X. Insert a brass fastener with a small cardboard donut washer between the strips so they do not rub. Open the wings loosely on the back.",
        tip: "Do not pinch fastener wings too tightly! The strips need clearance to slide.",
        safety_note: "Fastener wings have slight edges; press them flat.",
        visual_type: "x_assembly"
      },
      {
        step_number: 4,
        title: "Connect the Stages & Platform",
        instruction: "Connect the ends of the three X-units together to build a multi-stage tower. Fasten bottom to a flat base with one fixed pin and one sliding track. Push bottom feet together to elevate!",
        tip: "Test extending the lift: push the two bottom feet together to watch it rise!",
        safety_note: "Check that all split pins are secure so links do not pop off.",
        visual_type: "lift_complete"
      }
    ]
  },
  {
    id: "proj_test_cart",
    level_required: 1,
    title: "Smooth-Rolling Test Cart with Straw Bearings",
    description: "Construct the fundamental rolling chassis from Chapter 3! Mount low-friction axle sleeves using drinking straws and cardboard donut washers. Test straight-line rollout and diagnose wheel wobble!",
    category: "Cardboard Mechanics",
    difficulty: "Beginner",
    estimated_time: "30 mins",
    xp_reward: 110,
    badge_reward: null,
    order_index: 2,
    materials_list: [
      { id: "m1", name: "Corrugated cardboard chassis base (15x10 cm)", amount: "1 plate", optional: false, tip: "Rigid flat platform for the cart wheelbase." },
      { id: "m2", name: "Plastic drinking straws (bearing sleeves)", amount: "2 pcs", optional: false, tip: "Cut 1 cm shorter than axle width to serve as low-friction sleeve bearings." },
      { id: "m3", name: "Wooden skewers (smooth axles)", amount: "2 pcs", optional: false, tip: "Smooth cylindrical axles that spin freely inside straws." },
      { id: "m4", name: "Cardboard wheel discs (5 cm diameter)", amount: "4 discs", optional: false, tip: "Pierce holes exactly dead-center to prevent eccentric hopping!" },
      { id: "m5", name: "Cardboard donut washers / spacers", amount: "4 washers", optional: false, tip: "Glue between wheel and chassis so spinning rims don't rub." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Glue Straw Bearing Sleeves to Chassis Base",
        instruction: "Cut two drinking straw segments, each 9 cm long. Glue them across the underside of the cardboard chassis base at front and back. Use a ruler to ensure both straws are strictly parallel.",
        tip: "If straws are crooked, the cart will veer off course and crab-walk sideways!",
        safety_note: "Allow glue to fully cure before inserting axles.",
        visual_type: "straw_bearings"
      },
      {
        step_number: 2,
        title: "Cut Round Wheels & Punch Centered Axle Holes",
        instruction: "Trace and cut four identical 5 cm cardboard wheel discs. Find the exact center using diagonal cross-marks or a compass. Pierce clean axle holes using the tip of a wooden skewer.",
        tip: "Spin the wheel on a pencil tip before mounting—if it wobbles, re-center the hole.",
        safety_note: "Never punch holes with fingers directly beneath the skewer tip.",
        visual_type: "wheel_cutting"
      },
      {
        step_number: 3,
        title: "Add Cardboard Donut Spacers & Secure Wheels",
        instruction: "Slide a wooden axle through the front straw. Thread a small cardboard washer onto each end, then press the wheels on. Leave 1 mm of side-to-side clearance so the axle spins with zero bind.",
        tip: "Cardboard donut washers keep the spinning wheel face from grinding against the frame.",
        safety_note: "Trim sharp skewer ends with craft pliers.",
        visual_type: "wheel_assembly"
      },
      {
        step_number: 4,
        title: "Conduct the 3-Meter Rollout Test",
        instruction: "Give your cart a gentle push on a smooth flat floor. Measure the rollout distance and check if it travels in a straight line. If it veers left, check the right axle for friction or wobble!",
        tip: "Aim for a smooth 3-meter rollout with a single light push.",
        safety_note: "Keep the test runway clear of obstacles.",
        visual_type: "cart_rollout"
      }
    ]
  },
  {
    id: "proj_marble_coaster",
    level_required: 1,
    title: "Gravity-Fed Marble Coaster Run",
    description: "Design and construct a gravity marble coaster using paper tubes and cardboard channels. Learn about kinetic vs. potential energy, friction, and slope angles!",
    category: "Cardboard Mechanics",
    difficulty: "Beginner",
    estimated_time: "45 mins",
    xp_reward: 130,
    badge_reward: "badge_cardboard_pioneer",
    order_index: 3,
    materials_list: [
      { id: "m1", name: "Paper towel or toilet paper cardboard rolls", amount: "4-6 rolls", optional: false, tip: "Cut lengthwise to make half-pipe chutes." },
      { id: "m2", name: "Cardboard backing sheet or cardboard box wall", amount: "1 sheet", optional: false, tip: "Provides a vertical mounting surface for your tracks." },
      { id: "m3", name: "Masking tape or painter's tape", amount: "1 roll", optional: false, tip: "Makes repositioning tracks easy during test runs." },
      { id: "m4", name: "Standard glass marbles or wooden beads", amount: "2-3 marbles", optional: false, tip: "Test different weights to see how momentum changes speed." },
      { id: "m5", name: "Plastic catch cup or small paper box", amount: "1 pc", optional: false, tip: "Catch marbles safely at the end of the run." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Slice Tubes into Half-Pipes",
        instruction: "Carefully cut each paper roll lengthwise down both sides to create two U-shaped channel chutes.",
        tip: "Score straight lines with a pencil first to keep the channels even.",
        safety_note: "Always cut away from your fingers.",
        visual_type: "tube_cutting"
      },
      {
        step_number: 2,
        title: "Mount the Starting High Ramp",
        instruction: "Tape the first chute near the top of the backing board at a 30-degree incline. Test dropping a marble to verify momentum.",
        tip: "Steeper angles increase speed, but can cause marbles to jump the track on curves.",
        safety_note: "Ensure the base is stable and won't tip over.",
        visual_type: "angle_testing"
      },
      {
        step_number: 3,
        title: "Add Banked Turns & Chute Transitions",
        instruction: "Connect the next chute so it slopes in the opposite direction. Tilt the outer edge of the curve slightly upward to create a banked turn.",
        tip: "Banked curves prevent the marble from flying off due to inertia.",
        safety_note: "Smooth out any tape edges inside the track channel.",
        visual_type: "banked_turns"
      },
      {
        step_number: 4,
        title: "Time Trial & Catch Cup Setup",
        instruction: "Tape your catch cup at the finish line. Do 5 test runs with a stopwatch. Aim for a smooth, continuous run without stalls!",
        tip: "Try adding a funnel or a loop-de-loop if you want an extra challenge!",
        safety_note: "Keep small marbles away from young siblings or pets.",
        visual_type: "marble_finish"
      }
    ]
  },
  {
    id: "proj_rubber_drive",
    level_required: 1,
    title: "Rubber-Band Wind-Up Drive Racer",
    description: "Build a stored-energy vehicle powered by a wound rubber band axle from Chapter 4! Discover potential elastic energy, traction rubber tires, and smooth axle releases without tangling.",
    category: "Cardboard Mechanics",
    difficulty: "Beginner",
    estimated_time: "35 mins",
    xp_reward: 125,
    badge_reward: null,
    order_index: 4,
    materials_list: [
      { id: "m1", name: "Corrugated cardboard chassis base (18x8 cm)", amount: "1 plate", optional: false, tip: "Cut a central U-notch window so the elastic band can turn freely." },
      { id: "m2", name: "High-elasticity rubber bands", amount: "3 pcs", optional: false, tip: "Style A direct-axle wrap stores instant acceleration torque!" },
      { id: "m3", name: "Wooden skewer rear drive axle with tooth catch", amount: "1 skewer", optional: false, tip: "A tiny cardboard catch tooth holds the elastic loop securely." },
      { id: "m4", name: "Cardboard wheels with rubber band traction tires", amount: "4 wheels", optional: false, tip: "Stretch wide rubber bands over rims to maximize grip." },
      { id: "m5", name: "Straw bearing sleeves & cardboard donut washers", amount: "2 sets", optional: false, tip: "Keep the drive axle spinning with minimum frictional drag." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Notch the Rear Drive Axle & Glue Catch Tooth",
        instruction: "Cut a shallow center notch in the rear wooden skewer. Glue a tiny cardboard tooth or toothpick sliver to act as an anchor hook for the rubber band loop.",
        tip: "The tooth must slant slightly so the band slips off cleanly at maximum unwind.",
        safety_note: "Allow the glue joint to dry rock-hard before winding.",
        visual_type: "axle_notch"
      },
      {
        step_number: 2,
        title: "Mount Parallel Straw Bearings on Notched Chassis",
        instruction: "Cut a 4x4 cm rectangular window in the rear chassis floor. Glue the straw sleeves along the front and rear edges, ensuring the drive axle spans across the window.",
        tip: "The cutout window gives the rubber band room to wind without snagging.",
        safety_note: "Check that both axles are strictly parallel.",
        visual_type: "chassis_window"
      },
      {
        step_number: 3,
        title: "Fit High-Traction Tires Around Wheels",
        instruction: "Wrap wide rubber bands around the perimeter rims of all four cardboard wheels. Thread the axles through the straws and press the wheels on with donut spacers.",
        tip: "Without rubber band tires, cardboard wheels simply spin in place on smooth floors!",
        safety_note: "Leave 1 mm clearance between washer and straw.",
        visual_type: "traction_tires"
      },
      {
        step_number: 4,
        title: "Hook, Wind, & Sprint Launch Trials",
        instruction: "Anchor the rubber band to the front crossbar. Hook the other loop over the rear axle tooth. Roll the cart backward 6-8 turns to wind the band, set on the floor, and RELEASE!",
        tip: "Measure the sprint rollout with a tape measure. Aim for over 4 meters!",
        safety_note: "Keep hair and eyes clear of the spinning rear axle.",
        visual_type: "rubber_launch"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // LEVEL 2: Simple Machines, Drives & Pulleys (Ch. 4-6)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "proj_pulley_crane",
    level_required: 2,
    title: "Dual-Pulley Mechanical Crane",
    description: "Build an authentic tabletop crane with a compound block-and-tackle pulley system. Discover how looping line through multiple pulleys doubles your lifting strength!",
    category: "Simple Machines & Pulleys",
    difficulty: "Intermediate",
    estimated_time: "50 mins",
    xp_reward: 180,
    badge_reward: "badge_kinetic_king",
    order_index: 1,
    materials_list: [
      { id: "m1", name: "Heavy corrugated cardboard sheets for A-frame boom", amount: "3 sheets", optional: false, tip: "Truss patterns provide the strongest structural rigidity." },
      { id: "m2", name: "Plastic bottle caps or empty ribbon spools", amount: "2-4 caps", optional: false, tip: "Glue two bottle caps rim-to-rim to make a deep grooved pulley wheel!" },
      { id: "m3", name: "Strong nylon cord or braided cotton twine", amount: "2 meters", optional: false, tip: "Braided cord doesn't kink like wool or dental floss." },
      { id: "m4", name: "Wooden dowels (4mm) or sturdy pencils", amount: "3 pcs", optional: false, tip: "Act as rotating axles for pulley wheels and winch crank." },
      { id: "m5", name: "Metal paperclips or binder clips", amount: "2 pcs", optional: false, tip: "Bend into a heavy-duty cargo hook." },
      { id: "m6", name: "Washers, coins, or small stones (weights)", amount: "1 bag", optional: true, tip: "Use as cargo to measure lifting capacity." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Craft Grooved Pulley Wheels",
        instruction: "Take two matching bottle caps. Poke an axle hole dead-center through each. Glue the top rims together face-to-face so the center channel forms a pulley groove.",
        tip: "Heat the tip of a paperclip or use an awl to pierce clean center holes.",
        safety_note: "Ensure glue is fully set before mounting on axles.",
        visual_type: "pulley_wheel"
      },
      {
        step_number: 2,
        title: "Build the A-Frame Boom Structure",
        instruction: "Cut two triangular cardboard trusses and cross-brace them with cardboard struts to form an ultra-rigid A-frame. Mount the boom arm extending out at a 45-degree angle.",
        tip: "Triangles do not deform under load, giving your crane immense strength.",
        safety_note: "Use a weighted base or tape down the crane stand so it doesn't tip.",
        visual_type: "a_frame"
      },
      {
        step_number: 3,
        title: "Thread the Compound Cable Rigging",
        instruction: "Mount fixed Pulley A at the tip of the boom. Suspend movable Pulley B inside the cable loop with your cargo hook. Anchor one end to the boom tip, loop through Pulley B, over Pulley A, and down to the winch.",
        tip: "Pulling 20 cm of string lifts the weight 10 cm with half the effort!",
        safety_note: "Ensure the string stays seated in the groove without slipping.",
        visual_type: "cable_rigging"
      },
      {
        step_number: 4,
        title: "Install the Hand Crank Winch & Lift Test",
        instruction: "Pass a wooden dowel through the crane base and bend a crank handle from cardboard. Tie the free cord to the axle. Crank the handle to lift a cup of coins!",
        tip: "Add a cardboard ratchet pawl to prevent the spool from unwinding.",
        safety_note: "Do not exceed weight limits that bend the boom arm.",
        visual_type: "crane_complete"
      }
    ]
  },
  {
    id: "proj_gear_automaton",
    level_required: 2,
    title: "Cardboard Cam & Gear Automaton",
    description: "Design a mechanical kinetic toy driven by eccentric cams and gear followers. Turn rotary hand motion into lifelike dancing puppets!",
    category: "Simple Machines & Pulleys",
    difficulty: "Intermediate",
    estimated_time: "55 mins",
    xp_reward: 190,
    badge_reward: null,
    order_index: 2,
    materials_list: [
      { id: "m1", name: "Shoebox or rectangular cardboard frame", amount: "1 box", optional: false, tip: "Acts as the housing chassis for the camshaft." },
      { id: "m2", name: "Heavy chipboard or dense cardboard circles", amount: "4 discs", optional: false, tip: "Cut off-center to create snail cams or egg cams." },
      { id: "m3", name: "Wooden skewers (axles and follower rods)", amount: "4 skewers", optional: false, tip: "Guide rods must slide vertically with minimal friction." },
      { id: "m4", name: "Straw segments (bushings/bearings)", amount: "3 pcs", optional: false, tip: "Straws keep follower shafts strictly vertical." },
      { id: "m5", name: "Decorated character topper", amount: "1 cutout", optional: false, tip: "Color and personalize your puppet figure!" }
    ],
    steps: [
      {
        step_number: 1,
        title: "Chassis & Bearing Preparation",
        instruction: "Cut a 4cm window in the front of your shoebox. Glue a plastic drinking straw vertically through the center of the top lid to act as a low-friction follower guide.",
        tip: "Check that a skewer slides up and down through the straw effortlessly.",
        safety_note: "Keep axle holes perpendicular so the camshaft doesn't bind.",
        visual_type: "automaton_box"
      },
      {
        step_number: 2,
        title: "Craft the Eccentric Cam Profile",
        instruction: "Cut an oval or pear-shaped cam out of dense cardboard. Punch the axle hole off-center towards one end. Slide the cam onto the horizontal driveshaft skewer inside the box.",
        tip: "An egg-shaped cam creates a slow rise and sudden snap drop effect!",
        safety_note: "Secure the cam to the skewer with glue so it doesn't spin freely.",
        visual_type: "cam_profile"
      },
      {
        step_number: 3,
        title: "Assemble the Follower & Puppet",
        instruction: "Attach a round cardboard follower disc to the bottom of the vertical rod. Drop it through the guide straw so the disc rests on top of the cam. Glue your puppet to the top.",
        tip: "Add a metal nut or coin to the follower disc for gravity weighting.",
        safety_note: "Ensure the puppet doesn't collide with the ceiling as it rises.",
        visual_type: "follower_assembly"
      },
      {
        step_number: 4,
        title: "Rotate the Crank & Observe Motion",
        instruction: "Turn the hand crank 360 degrees. Watch continuous rotary motion convert into oscillating linear motion as your character springs to life!",
        tip: "Try pairing two out-of-phase cams for a swimming fish effect.",
        safety_note: "Inspect joints and re-tighten any loose skewers.",
        visual_type: "automaton_done"
      }
    ]
  },
  {
    id: "proj_robot_arm",
    level_required: 2,
    title: "Articulated Cardboard Robot Arm & Scoop",
    description: "Build a multi-jointed lifting robot arm with reinforced lever beams and a pivoting scoop bucket from Chapters 5 & 8. Learn how fulcrums, stiffener ribs, and pull-cords hoist cargo!",
    category: "Simple Machines & Pulleys",
    difficulty: "Intermediate",
    estimated_time: "45 mins",
    xp_reward: 185,
    badge_reward: null,
    order_index: 3,
    materials_list: [
      { id: "m1", name: "Heavy corrugated cardboard strips (25 cm)", amount: "4 strips", optional: false, tip: "Use for main boom and forearm lever beams." },
      { id: "m2", name: "Triangular cardboard stiffener ribs", amount: "8 pcs", optional: false, tip: "Glue along arm edges to form rigid U-channels that won't buckle." },
      { id: "m3", name: "Brass split pins & wooden skewer pivot fulcrums", amount: "6 pcs", optional: false, tip: "Allows elbow and wrist joints to pivot smoothly." },
      { id: "m4", name: "Braided pull string or heavy fishing line", amount: "1.5 meters", optional: false, tip: "Transmits tension force from hand lever to arm joints." },
      { id: "m5", name: "Cardboard scoop bucket & counterweight cup", amount: "1 set", optional: false, tip: "Fold a three-sided scoop with high rim walls for holding payload." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Cut Lever Arms & Glue Stiffener Flanges",
        instruction: "Cut two 25 cm arm beams. Glue narrow cardboard strips vertically along both edges to create rigid U-channel beams that cannot bend under heavy payloads.",
        tip: "The flutes in the stiffener ribs should run vertically for maximum stiffness.",
        safety_note: "Allow glue seams to dry completely before applying lifting loads.",
        visual_type: "stiffener_ribs"
      },
      {
        step_number: 2,
        title: "Assemble Pivoting Elbow & Fulcrum Joints",
        instruction: "Join the boom and forearm using a brass split pin and cardboard washer. Ensure the joint pivots with minimal play but does not bind or pinch.",
        tip: "A washer spacer stops cardboard faces from chafing and sticking.",
        safety_note: "Flatten split pin wings firmly.",
        visual_type: "arm_joints"
      },
      {
        step_number: 3,
        title: "Fold & Mount the Cardboard Scoop Bucket",
        instruction: "Fold a rectangular piece of cardboard into a scoop with high side walls. Mount it to the wrist pivot at the end of the forearm with a brass pin.",
        tip: "Score fold lines with a dull pencil before bending for sharp, clean corners.",
        safety_note: "Check that the scoop tilts through a full 90-degree dumping arc.",
        visual_type: "scoop_mount"
      },
      {
        step_number: 4,
        title: "Rig Pull-String Tension Control & Test Lift",
        instruction: "Anchor one end of the pull cord to the forearm above the elbow fulcrum. Thread through a guide loop on the boom. Pull the cord to elevate the arm and scoop up pennies!",
        tip: "Add a counterweight cup filled with washers to the back of the boom to balance the arm.",
        safety_note: "Do not overload the joint with excessive payload weights.",
        visual_type: "arm_complete"
      }
    ]
  },
  {
    id: "proj_trapdoor_scoop",
    level_required: 2,
    title: "Trap-Door Payload Delivery Scoop",
    description: "Engineer a specialized cardboard cargo scoop featuring a spring-loaded bottom trapdoor latch from Chapter 8! Slide under payloads, hoist them upward, and pull a release cord to drop cargo cleanly into target bins.",
    category: "Simple Machines & Pulleys",
    difficulty: "Intermediate",
    estimated_time: "45 mins",
    xp_reward: 175,
    badge_reward: null,
    order_index: 4,
    materials_list: [
      { id: "m1", name: "Heavy cardboard scoop housing (three-sided box channel)", amount: "1 box", optional: false, tip: "Cut with angled front leading lip for easy under-sliding." },
      { id: "m2", name: "Scored living-hinge bottom trapdoor panel", amount: "1 door", optional: false, tip: "Score paper liner along fold line for smooth downward swing." },
      { id: "m3", name: "Wooden skewer latch pin & trigger arm", amount: "1 pin", optional: false, tip: "Keeps the floor securely locked until triggered." },
      { id: "m4", name: "Light elastic band or spring return", amount: "1 band", optional: false, tip: "Maintains latch tension against vibrations during transit." },
      { id: "m5", name: "Braided pull-string release lanyard", amount: "1 meter", optional: false, tip: "Pull from afar to discharge payload instantly into catch bin." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Score & Fold Three-Sided Scoop Channel",
        instruction: "Cut a rectangular cardboard channel with two side walls and an open front. Bevel the front bottom edge into a sharp ramp wedge that can slide under objects effortlessly.",
        tip: "A 15-degree beveled leading lip glides under marbles and blocks smoothly.",
        safety_note: "Keep fingers clear when shaving the cardboard wedge tip.",
        visual_type: "scoop_channel"
      },
      {
        step_number: 2,
        title: "Fabricate the Hinged Floor Trapdoor",
        instruction: "Cut a bottom door panel slightly smaller than the scoop floor. Attach it at the front using a scored living hinge or cloth tape so it swings open downward.",
        tip: "Leave 2 mm side clearance so the swinging door never rubs or jams on side walls.",
        safety_note: "Test swing by hand to verify gravity drop.",
        visual_type: "trapdoor_hinge"
      },
      {
        step_number: 3,
        title: "Install Wooden Latch Pin & Preload Catch",
        instruction: "Mount a sliding skewer pin across the rear of the scoop. When pushed forward, it supports the rear edge of the trapdoor. Add a light rubber band to hold it in the locked position.",
        tip: "Bevel the latch pin tip so the door can snap shut automatically when raised.",
        safety_note: "Ensure the latch holds firmly when cargo is loaded.",
        visual_type: "latch_mechanism"
      },
      {
        step_number: 4,
        title: "Rig Release Lanyard & Conduct Drop Trials",
        instruction: "Tie the release lanyard to the latch pin. Scoop up a load of marbles or wooden blocks, lift into the air, position over a target cup, and pull the cord—WATCH IT DROP!",
        tip: "Practice 5 rapid pick-and-release cycles into different cups!",
        safety_note: "Place catch bin securely beneath drop point.",
        visual_type: "trapdoor_drop"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // LEVEL 3: Robotic Grippers, Linkages & Circuits (Ch. 5 & 8)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "proj_moving_jaws",
    level_required: 3,
    title: "Moving Jaws & Springy Claw Gripper",
    description: "Build authentic mechanical gripper jaws that clamp tightly around objects! Use mirrored dual-lever linkages, cross-guide pins, and rubber-band spring returns from Chapters 5 & 8.",
    category: "Basic Circuits & Robotics",
    difficulty: "Intermediate",
    estimated_time: "40 mins",
    xp_reward: 210,
    badge_reward: null,
    order_index: 1,
    materials_list: [
      { id: "m1", name: "Curved cardboard jaw blades (symmetrical pair)", amount: "2 jaws", optional: false, tip: "Cut serrated teeth along inner edge for textured mechanical bite!" },
      { id: "m2", name: "Cross-linkage push rods & center pull slide", amount: "3 rods", optional: false, tip: "Transmits linear pull into radial jaw rotation." },
      { id: "m3", name: "Brass paper fasteners & cardboard washers", amount: "8 pcs", optional: false, tip: "Provides smooth pivot vertexes at all 6 linkage nodes." },
      { id: "m4", name: "Small elastic rubber band (spring return)", amount: "1 band", optional: false, tip: "Pulls jaws open automatically when control handle is released." },
      { id: "m5", name: "Craft foam strips or adhesive weatherstripping", amount: "2 strips", optional: false, tip: "High-friction grip pads for clamping smooth objects." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Cut Symmetrical Jaw Blades & Cross-Link Struts",
        instruction: "Trace two matching curved jaw blades with inner gripping teeth. Cut four short linkage struts (6 cm each) to drive the mirrored closing action.",
        tip: "Stack both jaw templates together while cutting so tooth profiles match exactly.",
        safety_note: "Watch blade edges when cutting intricate tooth curves.",
        visual_type: "jaw_cutting"
      },
      {
        step_number: 2,
        title: "Assemble the Mirrored Four-Bar Cross Linkage",
        instruction: "Pin the base of both jaws to a central mounting plate. Connect the cross-link struts from each jaw to the central sliding actuator rod.",
        tip: "Ensure pivot pins have cardboard washers so links slide past each other smoothly.",
        safety_note: "Check that both sides open and close symmetrically.",
        visual_type: "jaw_linkage"
      },
      {
        step_number: 3,
        title: "Install Rubber Band Spring-Return Tension",
        instruction: "Hook a small rubber band between the outer heel of both jaw blades. When you pull the handle, the jaws close; when you release, the rubber band snaps them open!",
        tip: "Use a light elastic band so students don't need high hand force to close the grip.",
        safety_note: "Secure rubber band anchor pins with a dab of glue.",
        visual_type: "spring_return"
      },
      {
        step_number: 4,
        title: "Apply Foam Grip Pads & Test Payload Hold",
        instruction: "Stick high-friction craft foam or rubber tape along the inside face of both jaws. Test picking up a plastic cup, a wooden block, and a marker pen!",
        tip: "Foam conforms to irregular shapes, vastly improving gripping friction.",
        safety_note: "Inspect pins to ensure they don't bend under firm grip squeezes.",
        visual_type: "claw_test"
      }
    ]
  },
  {
    id: "proj_walking_linkage",
    level_required: 3,
    title: "Walking-Style Leg Linkage Rover",
    description: "Turn rotating crank motion into organic stepping strides! Build a four-bar Theo Jansen-inspired walking leg linkage that lifts, swings, and plants foot pads along an elliptical step path.",
    category: "Basic Circuits & Robotics",
    difficulty: "Intermediate",
    estimated_time: "50 mins",
    xp_reward: 230,
    badge_reward: null,
    order_index: 2,
    materials_list: [
      { id: "m1", name: "Cardboard leg link struts (thigh, shin, foot pad)", amount: "6 struts", optional: false, tip: "Follow Chapter 5 proportional dimensions for optimal step arc." },
      { id: "m2", name: "Wooden crank skewer & circular crank disk", amount: "1 set", optional: false, tip: "Offset hole creates eccentric rotational throw." },
      { id: "m3", name: "Brass paper fasteners with clearance washers", amount: "8 pcs", optional: false, tip: "Pivot joints must rotate with virtually zero friction." },
      { id: "m4", name: "Cardboard upright chassis stand", amount: "1 stand", optional: false, tip: "Supports the crankshaft and fixed hip pivot points." },
      { id: "m5", name: "High-traction rubber or silicone foot pads", amount: "2 pads", optional: false, tip: "Grips the floor during backward stance thrust." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Cut & Label Proportional Leg Link Segments",
        instruction: "Cut the three key link segments from dense cardboard: the triangular thigh link (8 cm), the lower shin link (10 cm), and the curved foot pad. Mark pivot holes precisely.",
        tip: "Exact hole spacing is critical for a smooth elliptical foot trajectory.",
        safety_note: "Stack matching left and right links to drill or punch together.",
        visual_type: "link_cutting"
      },
      {
        step_number: 2,
        title: "Assemble Hip & Knee Planar Pivot Vertices",
        instruction: "Pin the thigh and shin links together at the knee vertex using a brass fastener and cardboard washer. Fasten the hip pivot to the upright chassis.",
        tip: "Test the joint: it should drop and swing freely under gravity.",
        safety_note: "Do not pinch the brass wings too tightly.",
        visual_type: "leg_assembly"
      },
      {
        step_number: 3,
        title: "Connect Crank Throw Pin to Thigh Link",
        instruction: "Cut a 4 cm circular crank disk. Punch a hole 1.5 cm from the center. Insert a drive pin connecting the disk to the upper thigh link.",
        tip: "The distance from crank center to pin determines the step stride length!",
        safety_note: "Glue the crank disk securely to the drive skewer.",
        visual_type: "crank_connect"
      },
      {
        step_number: 4,
        title: "Rotate Crankshaft & Plot the Step Arc Ellipse",
        instruction: "Turn the crankshaft 360 degrees by hand. Watch the foot lift off the table, swing forward in an arc, press firmly down, and glide backward along the stance phase!",
        tip: "Hold a pencil against the foot pad over a paper sheet to draw the actual step curve.",
        safety_note: "Adjust links if the foot drags prematurely.",
        visual_type: "walking_test"
      }
    ]
  },
  {
    id: "proj_paper_circuit",
    level_required: 3,
    title: "Light-Up Origami Greeting Card",
    description: "Build an interactive paper circuit using conductive copper tape, surface-mount LEDs, and a coin cell battery switch. Learn circuit polarity, parallel branches, and push-button contact switches!",
    category: "Basic Circuits & Robotics",
    difficulty: "Intermediate",
    estimated_time: "40 mins",
    xp_reward: 200,
    badge_reward: "badge_circuit_spark",
    order_index: 3,
    materials_list: [
      { id: "m1", name: "Conductive copper foil tape with adhesive", amount: "1 meter", optional: false, tip: "Fold corners rather than cutting tape to preserve electrical conductivity!" },
      { id: "m2", name: "3V Coin cell battery (CR2032)", amount: "1 battery", optional: false, tip: "Smooth top is (+), textured bottom is (-)." },
      { id: "m3", name: "5mm or 3mm diffuse LEDs", amount: "2-3 LEDs", optional: false, tip: "Long leg is positive (Anode), short leg is negative (Cathode)!" },
      { id: "m4", name: "Heavy cardstock paper", amount: "1 sheet", optional: false, tip: "Creates the card canvas for your illustration." },
      { id: "m5", name: "Binder clip or corner fold flap", amount: "1 pc", optional: false, tip: "Acts as a momentary tactile switch." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Trace Circuit Schematic on Card",
        instruction: "Draw two parallel conductive tracks from the battery corner to the LED eyes/headlights on your card. Mark (+) in red and (-) in blue so polarity stays crystal clear.",
        tip: "Leave a gap for the LED legs and a fold-over tab for the switch.",
        safety_note: "Never directly short the (+) and (-) battery terminals with copper tape alone.",
        visual_type: "schematic_trace"
      },
      {
        step_number: 2,
        title: "Lay the Conductive Copper Foil",
        instruction: "Peel the backing and apply copper tape along the traced lines. At 90-degree corners, fold the tape back on itself and crease firmly without cutting to ensure continuous current flow.",
        tip: "Rub with the back of your fingernail or a popsicle stick to flatten tape.",
        safety_note: "Copper tape edges can be sharp; avoid sliding fingers fast along edges.",
        visual_type: "tape_laying"
      },
      {
        step_number: 3,
        title: "Mount the LED with Correct Polarity",
        instruction: "Bend the LED leads flat outward. Place the long leg (+) on the positive track and the short leg (-) on the negative track. Tape firmly with copper tape tabs.",
        tip: "Test before final taping: touch the coin battery to the traces to verify glow!",
        safety_note: "Standard coin batteries are 3V; do not connect to wall outlets.",
        visual_type: "led_mounting"
      },
      {
        step_number: 4,
        title: "Create the Push-to-Light Switch",
        instruction: "Seat the coin battery on the bottom trace. Fold the corner flap of the card so the top copper tape touches the battery (+) when pressed down. Release to turn off!",
        tip: "Add colorful artwork around the LED so the light illuminates stars or glowing robot eyes!",
        safety_note: "Keep coin cell batteries safely away from pets and small toddlers.",
        visual_type: "circuit_card_finish"
      }
    ]
  },
  {
    id: "proj_wiggle_bot",
    level_required: 3,
    title: "Bristle Wiggle-Bot: Vibration Robot",
    description: "Construct an autonomous, agile vibrating robot using an offset-mass DC vibration motor, toothbrush bristles, and an onboard battery pack. Experiment with directional friction and locomotion!",
    category: "Basic Circuits & Robotics",
    difficulty: "Intermediate",
    estimated_time: "45 mins",
    xp_reward: 220,
    badge_reward: "badge_bot_whisperer",
    order_index: 4,
    materials_list: [
      { id: "m1", name: "Angled toothbrush head or scouring brush", amount: "1 brush head", optional: false, tip: "Angled bristles turn vertical vibrations into rapid forward drive!" },
      { id: "m2", name: "Micro vibration coin motor or 3V DC motor", amount: "1 motor", optional: false, tip: "Eccentric mass creates rhythmic kinetic bouncing." },
      { id: "m3", name: "3V Coin cell holder or 1x AAA battery with leads", amount: "1 pack", optional: false, tip: "Provides lightweight mobile power." },
      { id: "m4", name: "Double-sided foam tape", amount: "4 strips", optional: false, tip: "Vibration-dampening adhesive holds components tightly." },
      { id: "m5", name: "Pipe cleaners and googly eyes", amount: "2 each", optional: false, tip: "Customize legs and aesthetic personality!" }
    ],
    steps: [
      {
        step_number: 1,
        title: "Prepare the Brush Chassis",
        instruction: "Cut the handle off an angled-bristle toothbrush, leaving only the head. Verify that the bristles slant slightly towards the back of the brush.",
        tip: "If bristles are straight, press them firmly with your thumb at a 15-degree backward tilt.",
        safety_note: "Use sturdy wire cutters or saw carefully when removing the plastic handle.",
        visual_type: "brush_prep"
      },
      {
        step_number: 2,
        title: "Mount the Vibration Motor",
        instruction: "Affix high-bond foam tape to the top flat surface of the brush head. Firmly press the vibration motor onto the tape, ensuring the counterweight can spin freely.",
        tip: "Centering the motor gives straight tracking; off-center makes it spin donuts!",
        safety_note: "Keep hair and fingers clear of spinning motor lobes.",
        visual_type: "motor_mount"
      },
      {
        step_number: 3,
        title: "Wire the Power & Balance",
        instruction: "Stick the battery holder on the rear. Connect the motor red wire to (+) and black to (-). Place on a smooth table and observe the buzzing sprint!",
        tip: "Wrap one pipe cleaner around the front as outrigger whiskers to keep the bot upright.",
        safety_note: "Disconnect battery when bot is resting to avoid draining power.",
        visual_type: "bot_wiring"
      },
      {
        step_number: 4,
        title: "Build an Obstacle Arena & Race!",
        instruction: "Build a cardboard perimeter arena. Set up cups and cardboard blocks. Measure how fast your Wiggle-Bot navigates mazes and challenges other bots!",
        tip: "Trim outer bristles to adjust turning speed and drift radius.",
        safety_note: "Store small spare parts in a container.",
        visual_type: "bot_arena"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // LEVEL 4: Moving Creatures & Smart Sensors (Ch. 7 & 11)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "proj_cam_creature",
    level_required: 4,
    title: "Flapping Wing & Bobbing Head Creature",
    description: "Combine shaped cams and articulated linkages to build a lifelike kinetic creature! Use an eccentric cam to bob the head while a twin-lobe pear cam rhythmically flaps hinged cardboard wings.",
    category: "Smart Inventions & Sensors",
    difficulty: "Advanced",
    estimated_time: "55 mins",
    xp_reward: 280,
    badge_reward: null,
    order_index: 1,
    materials_list: [
      { id: "m1", name: "Shoebox or cardboard chassis frame", amount: "1 box", optional: false, tip: "Encloses the rotating camshaft and supports the creature body." },
      { id: "m2", name: "Dense cardboard cam discs (circle & two-lobe)", amount: "3 discs", optional: false, tip: "Cut smooth continuous curves so followers ride without snagging." },
      { id: "m3", name: "Wooden skewers & drinking straw sleeve bushings", amount: "4 skewers", optional: false, tip: "Keeps rotating camshaft and vertical follower rods aligned." },
      { id: "m4", name: "Cardboard wings with scored living hinges", amount: "2 wings", optional: false, tip: "Score only the top layer of paper to allow easy flapping without tearing." },
      { id: "m5", name: "Small elastic tension return bands", amount: "2 bands", optional: false, tip: "Pulls wings and head follower down snugly against cam surface." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Build Chassis Box with Perpendicular Axle Bushings",
        instruction: "Pierce two matching holes through opposite sides of your shoebox. Glue straw bushings into the holes to support the horizontal camshaft skewer with low friction.",
        tip: "Ensure the skewer spins freely with no binding against the box walls.",
        safety_note: "Keep axle holes level across the chassis.",
        visual_type: "box_bushings"
      },
      {
        step_number: 2,
        title: "Carve & Key the Cam Profiles to Driveshaft",
        instruction: "Cut an off-center round cam for the bobbing head, and a two-lobe oval cam for the wings. Slide onto the driveshaft and lock with hot glue or cardboard collars.",
        tip: "Collar stops on both sides keep the cams from sliding left and right along the shaft.",
        safety_note: "Allow glue to cool before testing cam rotation.",
        visual_type: "cam_keying"
      },
      {
        step_number: 3,
        title: "Score Living Hinges & Mount Creature Wings",
        instruction: "Cut two cardboard wings. Score along the root with a dull butter knife to make living hinges. Glue the hinges to the box lid, extending follower levers over the cam.",
        tip: "Living hinges flex thousands of times without failing if the inner liner remains intact.",
        safety_note: "Do not cut completely through both cardboard liners.",
        visual_type: "wing_hinges"
      },
      {
        step_number: 4,
        title: "Crank Drive & Synchronized Motion Calibration",
        instruction: "Attach a cardboard hand crank to the shaft. Turn the crank and observe: the head bobs gracefully once per turn while the wings flap twice in rapid flutter!",
        tip: "Add a light rubber band from the wing lever to the floor if the wings float at high RPM.",
        safety_note: "Ensure characters don't catch on moving box edges.",
        visual_type: "creature_complete"
      }
    ]
  },
  {
    id: "proj_solar_tracker",
    level_required: 4,
    title: "Bio-Mimetic Solar Sunflower Tracker",
    description: "Engineer a cardboard solar flower that rotates towards sunlight. Integrates dual photoresistors (LDRs), a micro servo, and clean renewable solar energy principles!",
    category: "Smart Inventions & Sensors",
    difficulty: "Advanced",
    estimated_time: "60 mins",
    xp_reward: 300,
    badge_reward: "badge_solar_architect",
    order_index: 2,
    materials_list: [
      { id: "m1", name: "Mini 5V solar cell panel (60x60mm)", amount: "1 panel", optional: false, tip: "Monocrystalline or polycrystalline silicon panel." },
      { id: "m2", name: "Cardboard flower petals and stem chassis", amount: "1 kit", optional: false, tip: "Lightweight corrugated cardboard keeps servo strain low." },
      { id: "m3", name: "SG90 9g Micro Servo motor", amount: "1 motor", optional: false, tip: "Provides 180 degrees of precision pan rotation." },
      { id: "m4", name: "Light Dependent Resistors (LDR / photocell)", amount: "2 sensors", optional: false, tip: "Detects relative light intensity between left and right sides." },
      { id: "m5", name: "Central cardboard shadow divider fin", amount: "1 fin", optional: false, tip: "Casts a shadow on one sensor when the sun is off-angle!" }
    ],
    steps: [
      {
        step_number: 1,
        title: "Construct the Flower Head & Petals",
        instruction: "Cut a circular cardboard disc and radiate 8-12 triangular petals. Glue the mini solar cell into the center socket.",
        tip: "Angle petals slightly forward like a satellite dish to focus incident photons.",
        safety_note: "Do not puncture or bend the fragile glass solar panel face.",
        visual_type: "flower_craft"
      },
      {
        step_number: 2,
        title: "Install Dual LDR Optical Fins",
        instruction: "Mount one photoresistor on the left side of the panel and one on the right. Glue a 3cm cardboard shadow fin upright between them.",
        tip: "When the sun shines from the left, the fin casts a dark shadow on the right sensor, triggering rotation!",
        safety_note: "Ensure sensor leads are insulated with heat-shrink or tape.",
        visual_type: "ldr_fins"
      },
      {
        step_number: 3,
        title: "Mount the Azimuth Pan Servo",
        instruction: "Seat the micro servo in the cardboard stem upright. Fasten the servo horn arm directly to the back of the flower head disc.",
        tip: "Center the servo horn at 90 degrees before fastening so it can pivot 45 degrees left and right evenly.",
        safety_note: "Never force a servo horn by hand while powered; it strips nylon internal gears.",
        visual_type: "servo_stem"
      },
      {
        step_number: 4,
        title: "Calibrate & Heliotropic Tracking",
        instruction: "Take your tracker out into the yard or shine a flashlight around the room. Watch the sunflower smoothly track the light source to maximize energy harvest!",
        tip: "Measure output voltage with a multimeter: note the 30% power boost vs a static panel!",
        safety_note: "Protect the circuitry from rain and dew when testing outdoors.",
        visual_type: "solar_complete"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // LEVEL 5: Capstone Missions & STEM Certification (Ch. 11 & 12)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "proj_rescue_rover",
    level_required: 5,
    title: "Autonomous Cardboard Rescue Rover",
    description: "The ultimate capstone engineering mission from Chapter 11! Synthesize a rolling straw-bearing chassis (Ch. 3), rubber-band or winch drive (Ch. 4), and articulated gripper (Ch. 5 & 8) to navigate obstacles and rescue a stranded payload.",
    category: "Eco-Tech & Automation",
    difficulty: "Master",
    estimated_time: "75 mins",
    xp_reward: 350,
    badge_reward: "badge_master_cadet",
    order_index: 1,
    materials_list: [
      { id: "m1", name: "Heavy corrugated box chassis with bumper guard", amount: "1 box", optional: false, tip: "Wide wheelbase keeps rover stable during arm extension." },
      { id: "m2", name: "Straw-bearing wheel axles & traction tire bands", amount: "4 wheels", optional: false, tip: "Stretch wide rubber bands around rims for climbing grip!" },
      { id: "m3", name: "High-torque rubber-band winch drive transmission", amount: "1 drive", optional: false, tip: "Stores potential elastic energy to power rover forward." },
      { id: "m4", name: "Articulated grabber arm & pull-string claw", amount: "1 arm", optional: false, tip: "Synthesizes Ch. 5 arm and Ch. 8 claw end-effector." },
      { id: "m5", name: "Counterweight payload carrier compartment", amount: "1 box", optional: false, tip: "Balances forward payload moment arm to prevent nose-diving." },
      { id: "m6", name: "Mission obstacle props (cones, bridge ramps, payload)", amount: "1 set", optional: false, tip: "Create an authentic disaster rescue test course!" }
    ],
    steps: [
      {
        step_number: 1,
        title: "Fabricate Wide-Wheelbase Low-Center Chassis",
        instruction: "Cut a 20x12 cm chassis from heavy corrugated cardboard. Mount front and rear straw-bearing sleeves with wide stance spacing to prevent rollover.",
        tip: "A wide track width increases lateral stability by 60%.",
        safety_note: "Ensure axle straws are parallel so wheels track straight.",
        visual_type: "rover_chassis"
      },
      {
        step_number: 2,
        title: "Install High-Torque Winch Drive Transmission",
        instruction: "Mount an elastic rubber-band drive axle with high-traction wheels (wrapped in rubber bands). Test winding the axle to launch the rover across obstacles.",
        tip: "Rubber band tires provide 3x the traction of smooth cardboard on floors.",
        safety_note: "Do not overstretch dry rubber bands.",
        visual_type: "rover_drive"
      },
      {
        step_number: 3,
        title: "Mount Articulated Rescue Boom Arm & Gripper",
        instruction: "Install a stiffened cardboard boom arm with a string-operated claw gripper at the front of the rover. Route pull-strings to the rear operator console.",
        tip: "Use straw guide loops to route pull cords smoothly with zero snagging.",
        safety_note: "Fasten boom pivot securely to the chassis floor.",
        visual_type: "rover_arm"
      },
      {
        step_number: 4,
        title: "Calibrate Payload Balance & Counterweight Ratio",
        instruction: "Place a target rescue object in the gripper. Add pennies or washers to the rear balance compartment until the rover remains level without tilting forward.",
        tip: "Counterweight mass x rear distance must equal payload mass x front boom length!",
        safety_note: "Check that wheels remain in contact with the ground.",
        visual_type: "rover_balance"
      },
      {
        step_number: 5,
        title: "Execute Timed Obstacle Course & Retrieval Mission",
        instruction: "Deploy your Rescue Rover into the obstacle arena! Navigate over ramps, approach the stranded payload, close the gripper, and hoist it to safety!",
        tip: "Record your run on video for your MakerQuest STEM certification portfolio!",
        safety_note: "Celebrate your engineering triumph!",
        visual_type: "rover_mission"
      }
    ]
  },
  {
    id: "proj_lab_notebook",
    level_required: 5,
    title: "MakerQuest STEM Engineering Logbook",
    description: "Document, evaluate, and certify your entire maker journey using the official 5-Step Engineering Cycle from Chapter 12: Sketch -> Build -> Test -> Improve -> Explain!",
    category: "Eco-Tech & Automation",
    difficulty: "Beginner",
    estimated_time: "30 mins",
    xp_reward: 200,
    badge_reward: null,
    order_index: 2,
    materials_list: [
      { id: "m1", name: "Grid/lined engineering notebook or paper sheets", amount: "1 pad", optional: false, tip: "Isometric or square grid makes 3D mechanism sketching easy!" },
      { id: "m2", name: "Fine-line technical drawing pen & markers", amount: "2 pens", optional: false, tip: "Use contrasting colors for force arrows and moving parts." },
      { id: "m3", name: "Transparent ruler & angle protractor", amount: "1 each", optional: false, tip: "For accurate dimensioning and gear tooth angle checks." },
      { id: "m4", name: "Measuring tape or digital kitchen scale", amount: "1 tool", optional: false, tip: "Collect empirical data on distance and lifting load." },
      { id: "m5", name: "MakerQuest STEM Certification Certificate template", amount: "1 sheet", optional: false, tip: "Official sign-off document for your achievements!" }
    ],
    steps: [
      {
        step_number: 1,
        title: "Step 1 - SKETCH: Draft Isometric Views with Dimensions",
        instruction: "Draw an annotated isometric schematic of your mechanism. Label dimensions, pivot hole coordinates, and arrow vectors indicating motion flow.",
        tip: "Draw internal corrugation flute directions with parallel dashed lines.",
        safety_note: "Keep technical drawings neat and readable.",
        visual_type: "sketch_cycle"
      },
      {
        step_number: 2,
        title: "Step 2 - BUILD: Record Bill of Materials & Upcycled Sources",
        instruction: "List every material component, upcycled box source, fastener count, and tool used in your project build table.",
        tip: "Documenting parts lets other students reproduce your exact design!",
        safety_note: "Note any safety gear used during fabrication.",
        visual_type: "build_cycle"
      },
      {
        step_number: 3,
        title: "Step 3 - TEST: Benchmark Quantitative Performance Data",
        instruction: "Conduct 5 repetitive trial runs. Measure and record: rollout distance (meters), maximum cargo lifted (grams), or time to complete a cycle (seconds).",
        tip: "Compute the average and identify which trial had the greatest efficiency.",
        safety_note: "Record data honestly without altering outlier results.",
        visual_type: "test_cycle"
      },
      {
        step_number: 4,
        title: "Step 4 - IMPROVE: Diagnose Failures Using Chapter 10",
        instruction: "Identify any rubbing, slipping, or wobble using the Chapter 10 troubleshooting guide. Apply a targeted modification (e.g. spacer washer, triangle rib) and re-test!",
        tip: "Document the before-and-after improvement metric (e.g. +40% distance).",
        safety_note: "Only modify one variable at a time so you know what worked.",
        visual_type: "improve_cycle"
      },
      {
        step_number: 5,
        title: "Step 5 - EXPLAIN: Present Scientific Concepts & Earn Certificate",
        instruction: "Explain the physics principles powering your build (levers, cams, pulleys, or friction). Present to a teacher or peer and sign your STEM Mastery Certificate!",
        tip: "Teaching another cadet is the highest proof of engineering mastery.",
        safety_note: "Display your MakerQuest Certificate with pride!",
        visual_type: "explain_cycle"
      }
    ]
  },
  {
    id: "proj_heavy_lifter",
    level_required: 5,
    title: "Heavy-Lifter Compound Mechanical Machine",
    description: "Combine block-and-tackle compound pulleys, triangular truss booms, and a high-torque mechanical winch from Chapter 11! Hoist heavy soup cans and dense payloads with smooth mechanical advantage.",
    category: "Eco-Tech & Automation",
    difficulty: "Master",
    estimated_time: "65 mins",
    xp_reward: 320,
    badge_reward: null,
    order_index: 3,
    materials_list: [
      { id: "m1", name: "Reinforced cardboard A-frame tower with double-wall diagonal struts", amount: "2 towers", optional: false, tip: "Triangulation prevents boom twisting under 1kg loads." },
      { id: "m2", name: "Triple grooved pulley wheels (bottle cap compound block)", amount: "3 pulleys", optional: false, tip: "Compound cable loops distribute tension evenly." },
      { id: "m3", name: "Hand-cranked gear winch with cardboard ratchet pawl", amount: "1 winch", optional: false, tip: "One-way clicker holds heavy weight at any height automatically!" },
      { id: "m4", name: "Braided nylon hoisting cord & wire cargo hook", amount: "3 meters", optional: false, tip: "High-strength low-stretch line preserves lifting efficiency." },
      { id: "m5", name: "Payload cargo bucket & calibrated weights (soup can / rocks)", amount: "1 set", optional: false, tip: "Measure maximum load capacity and displacement." }
    ],
    steps: [
      {
        step_number: 1,
        title: "Fabricate Double-Wall Triangular Truss Tower",
        instruction: "Cut two matching triangular A-frames from double-wall corrugated cardboard. Cross-brace them with horizontal box-beams to create a wide, non-tipping base tower.",
        tip: "Orient corrugations vertically so legs resist compressive buckling.",
        safety_note: "Weight the base with two books or tape firmly to the table.",
        visual_type: "truss_tower"
      },
      {
        step_number: 2,
        title: "Assemble 3-Wheel Compound Block Rigging",
        instruction: "Mount two fixed pulleys at the crane boom apex and suspend one movable pulley within the cable loop. Thread the hoisting cord through the system to establish compound advantage.",
        tip: "Ensure cable loops run strictly in the center grooves with zero friction rubs.",
        safety_note: "Test free-running line before loading cargo weights.",
        visual_type: "compound_rigging"
      },
      {
        step_number: 3,
        title: "Craft & Install Anti-Reverse Ratchet Pawl",
        instruction: "Cut a toothed gear disc and an angled pivot pawl arm. Mount next to the winch drum so it clicks smoothly when winding upward and drops into teeth to lock against back-spinning.",
        tip: "A small rubber band pulls the pawl arm down against the gear teeth.",
        safety_note: "Verify the ratchet holds steady under full payload load.",
        visual_type: "ratchet_pawl"
      },
      {
        step_number: 4,
        title: "Conduct Maximum Load Capacity Stress Testing",
        instruction: "Suspend a full soup can (approx. 400-500g) on the cargo hook. Turn the winch handle effortlessly to hoist the can to the top of the tower! Measure required cable pull distance.",
        tip: "Notice that pulling 40 cm of cord lifts the soup can 20 cm with half the effort!",
        safety_note: "Do not drop heavy soup cans onto feet or bare floors.",
        visual_type: "lifter_test"
      }
    ]
  }
];

const CHALLENGES = [
  // ══════════════════════════════════════════════════════════════════
  // Checkpoint Challenge 1: Level 1 -> Level 2
  // Structural Rigidity, Axle Alignment & Friction Diagnostics (Ch. 10)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "chal_checkpoint_1",
    level_required: 1,
    level_target: 2,
    title: "Level 1 Checkpoint: Structural Mechanics & Friction Lab",
    description: "Put your Cardboard Engineering instincts to the test! Solve real-world troubleshooting scenarios from Chapter 10 to earn your Level 2 Maker License and unlock Simple Machines & Pulleys.",
    category: "Mechanics & Structures",
    type: "scenario_puzzle",
    xp_reward: 150,
    badge_reward: "badge_troubleshooter_ace",
    questions: [
      {
        id: "q1_1",
        scenario: "Maya is testing her Marble Coaster. When the marble enters the sharp 90-degree curve after a steep hill, it repeatedly flies over the outer track wall onto the floor instead of following the path.",
        question: "What is the most effective mechanical fix Maya should apply to keep the marble on track?",
        options: [
          "Grease the marble with cooking oil so it travels with zero resistance",
          "Increase the banking angle of the outer curved wall and lower the hill height to manage momentum",
          "Add extra weights inside the marble to make it heavier",
          "Remove the curve entirely and only make straight tracks"
        ],
        correct_index: 1,
        explanation: "Centripetal force is required to steer an object around a curve! Banked curves angle inward so gravity and normal force redirect velocity safely, preventing flyouts from excess inertia.",
        hint: "Think about how race car tracks and bobsled courses bank their curves on high-speed turns!",
        topic: "Kinematics & Inertia"
      },
      {
        id: "q1_2",
        scenario: "Devon built a Cardboard Scissor Lift. When he pushes the bottom handles together, the lift binds, jams, and bends the cardboard arms instead of smoothly raising upward.",
        question: "Which of the following is the most likely root cause and solution?",
        options: [
          "The brass split pin fasteners are pinched too tightly against the cardboard; loosen them slightly so struts can pivot freely",
          "Cardboard cannot expand vertically; scissor linkages only work horizontally",
          "The struts need to be glued permanently at the intersections",
          "He needs to use 100 split pins per joint"
        ],
        correct_index: 0,
        explanation: "Scissor linkages rely on rotational clearance at every pivot vertex. Pinched or over-tightened fasteners create excessive friction, resulting in strut buckling.",
        hint: "Check if the arms can swing easily around the center pin without pinching cardboard fibres.",
        topic: "Mechanical Linkages"
      },
      {
        id: "q1_3",
        scenario: "You are designing a cardboard bridge tower that must support a 1-kilogram water bottle without sagging or twisting.",
        question: "Which geometric cross-section provides the highest strength-to-weight ratio against bending forces?",
        options: [
          "A single flat sheet of horizontal cardboard",
          "Interlocking triangular truss webbing (triangulation)",
          "A loose stack of flat square sheets",
          "A soft crumpled cardboard ball"
        ],
        correct_index: 1,
        explanation: "Triangles are the only polygon with fixed angles when side lengths are constant. Triangular trusses distribute tensile and compressive forces across joints without deforming!",
        hint: "Look at modern crane booms and bridge structures—what geometric shape dominates?",
        topic: "Structural Engineering"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // Checkpoint Challenge 2: Level 2 -> Level 3
  // Mechanical Advantage, Drives & Gear Diagnostics (Ch. 6 & 10)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "chal_checkpoint_2",
    level_required: 2,
    level_target: 3,
    title: "Level 2 Checkpoint: Mechanical Advantage & Gear Diagnostics",
    description: "Diagnose mechanical leverage, torque, pulley systems, and gear ratios to earn Level 3: Basic Circuits & Breadboarding access!",
    category: "Simple Machines",
    type: "scenario_puzzle",
    xp_reward: 200,
    badge_reward: "badge_troubleshooter_ace",
    questions: [
      {
        id: "q2_1",
        scenario: "Carlos wants to lift a heavy 10-kg toolbox into his treehouse using a block-and-tackle pulley system with 2 supporting rope segments on a movable pulley.",
        question: "Neglecting friction, how much pulling force must Carlos exert to lift the 10-kg weight?",
        options: [
          "20 kg of force (doubles the effort)",
          "10 kg of force (exact same effort)",
          "5 kg of force (effort is halved, mechanical advantage of 2)",
          "1 kg of force"
        ],
        correct_index: 2,
        explanation: "A movable pulley distributes the load equally across its 2 supporting cable strands. Each strand holds 5 kg, so Carlos only needs to pull with 5 kg of effort!",
        hint: "Mechanical Advantage = Total Load / Number of supporting rope strands.",
        topic: "Pulleys & Mechanical Advantage"
      },
      {
        id: "q2_2",
        scenario: "In an automaton project, a small drive gear with 10 teeth rotates at 60 RPM and meshes directly with a large driven gear that has 30 teeth.",
        question: "What will happen to the speed and torque of the large 30-tooth gear?",
        options: [
          "It rotates 3x faster (180 RPM) with 1/3 the torque",
          "It rotates 3x slower (20 RPM) with 3x higher torque",
          "It spins in reverse at 60 RPM with no change in torque",
          "It locks up and cannot rotate"
        ],
        correct_index: 1,
        explanation: "Gear ratio is 30:10 = 3:1. Speed decreases by a factor of 3 (60 / 3 = 20 RPM), while torque increases by 3x! Ideal for turning fast motors into strong lifters.",
        hint: "Larger output gears trade rotational velocity for greater rotational muscle (torque)!",
        topic: "Gear Ratios & Power Transfer"
      },
      {
        id: "q2_3",
        scenario: "A maker is using a hand crank connected to a camshaft. As the cam rotates, the vertical follower shaft jams sideways inside the guide hole instead of lifting cleanly.",
        question: "How should the maker fix the binding follower?",
        options: [
          "Remove the camshaft and spin it with a drill",
          "Increase the length of the guide sleeve (bushing) and add low-friction straw lining to prevent tilting",
          "Bend the follower rod into an S-curve",
          "Shorten the follower so it no longer touches the cam"
        ],
        correct_index: 1,
        explanation: "As an eccentric cam turns, it exerts upward and lateral shear force. A longer, low-friction guide bushing counteracts tipping torque and keeps the shaft strictly vertical.",
        hint: "A deeper sleeve stops the rod from tilting and catching on hole corners.",
        topic: "Kinematic Linkages"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // Checkpoint Challenge 3: Level 3 -> Level 4
  // Circuit Diagnostics, Gripper Geometry & Polarity (Ch. 8 & 10)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "chal_checkpoint_3",
    level_required: 3,
    level_target: 4,
    title: "Level 3 Checkpoint: Circuit Diagnostics & Polarity Mastery",
    description: "Troubleshoot breadboard glitches, LED polarity, and current flow to prove your electronics expertise and unlock Level 4: Robotics & Smart Inventions!",
    category: "Electronics & Circuits",
    type: "scenario_puzzle",
    xp_reward: 250,
    badge_reward: "badge_troubleshooter_ace",
    questions: [
      {
        id: "q3_1",
        scenario: "A student tapes a red LED to a 3V coin cell battery in a greeting card circuit, but the LED refuses to illuminate. The battery tests good with a multimeter at 3.1V.",
        question: "What is the very first diagnostic step the student should perform?",
        options: [
          "Flip the LED polarity: connect the longer lead (anode) to (+) and shorter lead (cathode) to (-)",
          "Connect five more 3V batteries in series to force 15V into the LED",
          "Cut the copper tape into pieces",
          "Replace the wire with yarn"
        ],
        correct_index: 0,
        explanation: "LEDs are Light Emitting Diodes—they are one-way semiconductor valves! Current can only flow from Anode (+) to Cathode (-). Reversing the legs blocks current and leaves the diode dark.",
        hint: "Remember: Long lead = Positive (+). Diodes only conduct in forward-bias!",
        topic: "Diode Polarity"
      },
      {
        id: "q3_2",
        scenario: "You have two identical 3V white LEDs connected to a single 3V coin battery. In Circuit A, they are wired in series. In Circuit B, they are wired in parallel.",
        question: "Why do the LEDs glow brightly in Circuit B (parallel) but remain dark in Circuit A (series)?",
        options: [
          "Series circuits consume no power",
          "Each white LED requires ~3.0V forward voltage; series splits the 3V into only 1.5V each (below threshold), while parallel supplies full 3V across both",
          "Parallel circuits create extra batteries magically",
          "White LEDs can only be connected in single loops"
        ],
        correct_index: 1,
        explanation: "In a series circuit, supply voltage is divided across loads (3V / 2 = 1.5V). Since white LEDs need ~3V to conduct, 1.5V cannot overcome the bandgap! Parallel wiring supplies 3V to both branches.",
        hint: "In series, voltages divide; in parallel, each branch receives equal system voltage.",
        topic: "Series vs Parallel Circuits"
      },
      {
        id: "q3_3",
        scenario: "Your Bristle Wiggle-Bot vibrates vigorously, but instead of moving forward across the table, it simply spins tightly in one spot like a top.",
        question: "What modification will redirect the vibration into fast linear forward motion?",
        options: [
          "Trim or angle all bristles so they uniformly lean backward at an angle, directing downward vibration into backward kick",
          "Remove the motor completely",
          "Make the brush head round like a sphere",
          "Tape heavy stones to the side"
        ],
        correct_index: 0,
        explanation: "Bristle-bot locomotion uses asymmetric directional friction. Angled bristles bend easily in one direction and catch firmly in the other, converting omnidirectional vibration into coordinated forward thrust!",
        hint: "Directional bias in friction converts reciprocal vibration into forward drive.",
        topic: "Vibrational Locomotion"
      }
    ]
  },

  // ══════════════════════════════════════════════════════════════════
  // Checkpoint Challenge 4: Level 4 -> Level 5
  // Kinematic Synchronization & Cam Tuning Lab (Ch. 10 & 11)
  // ══════════════════════════════════════════════════════════════════
  {
    id: "chal_checkpoint_4",
    level_required: 4,
    level_target: 5,
    title: "Level 4 Checkpoint: Kinematic Synchronization & Cam Tuning Lab",
    description: "Diagnose harmonic camshaft profiles, living hinges, and heliotropic sensor feedback loops to unlock Level 5: Master Maker Summit & Capstone Missions!",
    category: "Kinematics & Sensors",
    type: "scenario_puzzle",
    xp_reward: 300,
    badge_reward: "badge_troubleshooter_ace",
    questions: [
      {
        id: "q4_1",
        scenario: "When turning the camshaft on the Moving Creature automaton at higher speeds, the follower arm floats and bounces off the cam lobe instead of tracking its profile smoothly.",
        question: "What mechanical component should the engineer install to keep the follower seated against the cam?",
        options: [
          "A rubber band or spring tension return pulling the follower downward against the cam",
          "Remove the follower entirely and replace it with water",
          "Grease the camshaft with sticky syrup",
          "Spin the crankshaft even faster"
        ],
        correct_index: 0,
        explanation: "At high rotational speeds, momentum overcomes gravity and causes cam followers to float. An elastic return spring or rubber band exerts continuous downward preload, guaranteeing continuous contact!",
        hint: "Automotive engine valves use springs for the exact same reason!",
        topic: "Cam Kinematics & Preload"
      },
      {
        id: "q4_2",
        scenario: "You want your automaton creature wings to flap twice as fast as its bobbing head, using a single unified driveshaft turned by one hand crank.",
        question: "How should you shape the cam driving the wing mechanism compared to the head cam?",
        options: [
          "Make the wing cam a single round eccentric disc",
          "Cut a two-lobe (egg or butterfly) cam profile with two distinct peaks per 360-degree rotation",
          "Cut a completely flat square block",
          "Drill the wing cam hole directly in the exact center of a perfect circle"
        ],
        correct_index: 1,
        explanation: "A two-lobe cam has two distinct lift peaks spaced around its circumference. In a single 360-degree shaft rotation, it lifts and drops the follower twice, doubling the flapping frequency without needing gears!",
        hint: "Number of lobes on a cam = number of lift cycles per revolution.",
        topic: "Cam Profiles & Harmonic Frequency"
      },
      {
        id: "q4_3",
        scenario: "In the Bio-Mimetic Solar Sunflower Tracker, why is a vertical central shadow divider fin placed directly between the two Light Dependent Resistors (LDRs)?",
        question: "What role does the shadow fin play in closed-loop feedback?",
        options: [
          "It insulates the solar panel from overheating",
          "It is purely decorative to look like sunflower seeds",
          "When the light source is off-axis, the fin casts a shadow onto one sensor, creating a voltage difference that triggers the servo to rotate towards balance",
          "It acts as an antenna for Wi-Fi signals"
        ],
        correct_index: 2,
        explanation: "The shadow divider fin creates an optical differential: when the sun moves, one sensor drops into shadow while the other remains illuminated. The difference in resistance tells the microcontroller or comparator circuit which way to steer!",
        hint: "Without the fin, both sensors would see similar ambient light and could not detect the sun’s angle.",
        topic: "Optical Feedback & Heliotropism"
      }
    ]
  }
];

const DEMO_USERS = [
  {
    id: "usr_alex_maker",
    name: "Alex Rivera",
    email: "alex@makerquest.edu",
    password: "maker123", // Will be hashed with salt
    avatar: "🦊",
    current_xp: 320,
    current_level: 2,
    unlocked_badges: [
      "badge_first_spark",
      "badge_cardboard_pioneer",
      "badge_material_collector",
      "badge_troubleshooter_ace",
      "badge_mechanism_maestro"
    ],
    streak_days: 4,
    // Alex has completed Level 1 projects and Checkpoint 1!
    progress: [
      {
        item_type: "project",
        item_id: "proj_scissor_lift",
        status: "completed",
        checklist_state: ["m1", "m2", "m3", "m4", "m5", "m6"],
        proof_notes: "Built this with an old cereal box! The brass split pins made it expand super smoothly up to 30cm high.",
        proof_image: "demo_scissor_lift.jpg",
        xp_awarded: 120
      },
      {
        item_type: "project",
        item_id: "proj_test_cart",
        status: "completed",
        checklist_state: ["m1", "m2", "m3", "m4", "m5"],
        proof_notes: "Mounted drinking straw sleeve bearings and cardboard donut spacers. Rolled 3.2 meters straight across the floor without wobbling!",
        proof_image: "demo_test_cart.jpg",
        xp_awarded: 110
      },
      {
        item_type: "project",
        item_id: "proj_marble_coaster",
        status: "completed",
        checklist_state: ["m1", "m2", "m3", "m4", "m5"],
        proof_notes: "Added two banked turns and a funnel drop. The marble completed 10 runs without jumping track!",
        proof_image: "demo_marble_run.jpg",
        xp_awarded: 130
      },
      {
        item_type: "challenge",
        item_id: "chal_checkpoint_1",
        status: "completed",
        score: 100,
        proof_notes: "Aced the structural stability and friction diagnostics!",
        xp_awarded: 150
      },
      {
        item_type: "project",
        item_id: "proj_pulley_crane",
        status: "in_progress",
        checklist_state: ["m1", "m2", "m3"],
        completed_steps: [1, 2],
        proof_notes: "",
        xp_awarded: 0
      }
    ]
  },
  {
    id: "usr_sam_newbie",
    name: "Sam Chen",
    email: "sam@makerquest.edu",
    password: "maker123",
    avatar: "🚀",
    current_xp: 50,
    current_level: 1,
    unlocked_badges: ["badge_first_spark"],
    streak_days: 1,
    progress: [
      {
        item_type: "project",
        item_id: "proj_scissor_lift",
        status: "in_progress",
        checklist_state: ["m1", "m2"],
        completed_steps: [1],
        proof_notes: "",
        xp_awarded: 0
      }
    ]
  }
];

module.exports = {
  BADGES,
  PROJECTS,
  CHALLENGES,
  DEMO_USERS
};
