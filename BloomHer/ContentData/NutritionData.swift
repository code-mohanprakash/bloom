import Foundation

// MARK: - NutritionData

/// Static content store for all nutrition tips in the BloomHer app.
///
/// Tips are keyed by cycle phase and pregnancy context. Source attributions follow
/// NHS, WHO, and Institute of Medicine (IOM) guidelines. Use the helper methods to
/// retrieve contextually appropriate content rather than filtering `tips` directly.
enum NutritionData {

    // MARK: - Full Collection

    static let tips: [NutritionTip] = menstrualTips
        + follicularTips
        + ovulationTips
        + lutealTips
        + pregnancyTrimester1Tips
        + pregnancyTrimester2Tips
        + pregnancyTrimester3Tips
        + generalTips

    // MARK: - Query Helpers

    /// All tips associated with a given cycle phase, including general tips
    /// (where `phase == nil`).
    static func tips(for phase: CyclePhase) -> [NutritionTip] {
        tips.filter { $0.phase == phase || ($0.phase == nil && !$0.isPregnancy) }
    }

    /// All tips specific to a pregnancy trimester.
    static func pregnancyTips(trimester: Int) -> [NutritionTip] {
        tips.filter { $0.isPregnancy && ($0.trimester == trimester || $0.trimester == nil) }
    }

    /// All pregnancy tips regardless of trimester.
    static var allPregnancyTips: [NutritionTip] {
        tips.filter { $0.isPregnancy }
    }

    // MARK: - Menstrual Phase Tips
    // Goal: replenish iron lost during bleeding, reduce cramping, support energy.

    private static let menstrualTips: [NutritionTip] = [
        NutritionTip(
            id: "men-nut-001",
            title: "Boost Iron with Leafy Greens",
            description: "Menstruation depletes iron stores. Spinach, kale, and Swiss chard provide non-haem iron alongside folate. Pair with a squeeze of lemon to boost absorption with vitamin C.",
            foods: ["Spinach", "Kale", "Swiss chard", "Rocket"],
            nutrient: "Iron",
            phase: .menstrual,
            dailyAmount: "14.8mg",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-002",
            title: "Red Meat for Haem Iron",
            description: "Haem iron from red meat is absorbed two to three times more efficiently than plant sources. A small portion of lean beef or lamb two to three times per week helps counter menstrual iron loss.",
            foods: ["Lean beef", "Lamb", "Liver (in moderation)"],
            nutrient: "Iron",
            phase: .menstrual,
            dailyAmount: "14.8mg",
            icon: "nutrition",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-003",
            title: "Lentils and Legumes",
            description: "Lentils are one of the richest plant-based iron sources. They also deliver protein and fibre, supporting sustained energy when fatigue is common during menstruation.",
            foods: ["Red lentils", "Green lentils", "Black beans", "Chickpeas"],
            nutrient: "Iron",
            phase: .menstrual,
            dailyAmount: "14.8mg",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-004",
            title: "Magnesium to Ease Cramps",
            description: "Magnesium relaxes smooth muscle, which can reduce the intensity of menstrual cramps. Dark chocolate (70%+ cacao) is a delicious source alongside nuts and seeds.",
            foods: ["Dark chocolate (70%+)", "Almonds", "Pumpkin seeds", "Cashews", "Edamame"],
            nutrient: "Magnesium",
            phase: .menstrual,
            dailyAmount: "270–300mg",
            icon: "bolt",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-005",
            title: "Anti-Inflammatory Spices",
            description: "Turmeric contains curcumin, a potent anti-inflammatory compound that may reduce prostaglandin activity linked to period pain. Ginger has similar analgesic properties supported by clinical evidence.",
            foods: ["Turmeric", "Ginger", "Cinnamon", "Cardamom"],
            nutrient: "Curcumin / Gingerols",
            phase: .menstrual,
            icon: "flame",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-006",
            title: "Soothing Warm Soups",
            description: "Warm, easy-to-digest soups nourish the body during menstruation without demanding much digestive energy. Bone broth adds collagen and electrolytes to support recovery.",
            foods: ["Bone broth", "Lentil soup", "Miso broth", "Tomato soup"],
            nutrient: "Electrolytes",
            phase: .menstrual,
            icon: "selfcare-relaxation",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-007",
            title: "Chamomile Tea for Cramp Relief",
            description: "Chamomile tea contains glycine, which relaxes uterine muscle spasms. Two to three cups per day during menstruation may reduce cramping and improve sleep quality.",
            foods: ["Chamomile tea", "Raspberry leaf tea", "Peppermint tea"],
            nutrient: "Glycine / Flavonoids",
            phase: .menstrual,
            icon: "selfcare-relaxation",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-008",
            title: "Omega-3 to Reduce Inflammation",
            description: "Omega-3 fatty acids compete with pro-inflammatory arachidonic acid, potentially reducing period pain. Oily fish eaten two to three times a week delivers a meaningful dose.",
            foods: ["Salmon", "Mackerel", "Sardines", "Walnuts", "Flaxseeds"],
            nutrient: "Omega-3",
            phase: .menstrual,
            icon: "nutrition",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-009",
            title: "Vitamin C to Enhance Iron Absorption",
            description: "Eating vitamin C-rich foods alongside iron-rich plant foods converts non-haem iron to a more absorbable form, significantly boosting uptake.",
            foods: ["Bell peppers", "Kiwi", "Strawberries", "Broccoli", "Orange juice"],
            nutrient: "Vitamin C",
            phase: .menstrual,
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "men-nut-010",
            title: "Limit Caffeine and Alcohol",
            description: "Both caffeine and alcohol can increase anxiety, disrupt sleep, and worsen breast tenderness during menstruation. Swap one coffee for herbal tea to support rest and recovery.",
            foods: ["Herbal tea", "Decaf coffee", "Sparkling water with lemon"],
            nutrient: "Hydration",
            phase: .menstrual,
            icon: "drop",
            source: "NHS"
        ),
    ]

    // MARK: - Follicular Phase Tips
    // Goal: support oestrogen metabolism, gut health, and rising energy.

    private static let follicularTips: [NutritionTip] = [
        NutritionTip(
            id: "fol-nut-001",
            title: "Fermented Foods for Gut Health",
            description: "The oestrobolome — the collection of gut microbes that metabolise oestrogen — influences hormonal balance. Fermented foods feed beneficial bacteria and support healthy oestrogen clearance.",
            foods: ["Kimchi", "Sauerkraut", "Kefir", "Natural yogurt", "Kombucha"],
            nutrient: "Probiotics",
            phase: .follicular,
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-002",
            title: "Lean Proteins for Muscle Repair",
            description: "Rising energy in the follicular phase makes it an ideal time for more active movement. Lean proteins support muscle repair and provide steady energy without blood sugar spikes.",
            foods: ["Chicken breast", "Turkey", "Tofu", "Greek yogurt", "Eggs"],
            nutrient: "Protein",
            phase: .follicular,
            dailyAmount: "0.8–1g per kg body weight",
            icon: "figure-stand",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-003",
            title: "Complex Carbohydrates for Energy",
            description: "Complex carbs provide slow-release glucose that fuels the follicular energy surge. Whole grains also deliver B vitamins essential for oestrogen metabolism.",
            foods: ["Oats", "Quinoa", "Brown rice", "Barley", "Wholegrain bread"],
            nutrient: "B Vitamins",
            phase: .follicular,
            icon: "bolt",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-004",
            title: "Sprouted Seeds and Pulses",
            description: "Sprouting increases bioavailability of nutrients and reduces anti-nutrients. Sprouted lentils, chickpeas, and broccoli sprouts (rich in sulforaphane) support liver detoxification of excess oestrogen.",
            foods: ["Sprouted lentils", "Broccoli sprouts", "Sprouted chickpeas", "Alfalfa sprouts"],
            nutrient: "Sulforaphane",
            phase: .follicular,
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-005",
            title: "Vitamin B6 for Hormone Regulation",
            description: "Vitamin B6 is involved in the synthesis of neurotransmitters and the regulation of hormonal activity. It is particularly helpful for managing mood as oestrogen begins to rise.",
            foods: ["Bananas", "Chickpeas", "Salmon", "Potatoes (with skin)", "Sunflower seeds"],
            nutrient: "Vitamin B6",
            phase: .follicular,
            dailyAmount: "1.4mg",
            icon: "book",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-006",
            title: "Light Salads and Raw Vegetables",
            description: "As energy rises and digestion is typically robust during the follicular phase, the body handles raw, fibre-rich foods well. Cruciferous vegetables help the liver process hormones efficiently.",
            foods: ["Broccoli", "Cauliflower", "Brussels sprouts", "Cabbage", "Mixed leaves"],
            nutrient: "Fibre / Indole-3-carbinol",
            phase: .follicular,
            icon: "nutrition",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-007",
            title: "Flaxseeds for Phytoestrogen Balance",
            description: "Flaxseeds contain lignans — phytoestrogens that can modulate oestrogen receptor activity. One to two tablespoons ground per day supports hormonal balance without disrupting it.",
            foods: ["Ground flaxseeds", "Flaxseed oil", "Chia seeds"],
            nutrient: "Lignans",
            phase: .follicular,
            dailyAmount: "1–2 tbsp ground",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "fol-nut-008",
            title: "Zinc to Support Follicle Development",
            description: "Zinc plays a direct role in follicle growth and ovulation. Including zinc-rich foods during the follicular phase primes the body for a healthy ovulatory event.",
            foods: ["Pumpkin seeds", "Beef", "Lentils", "Hemp seeds", "Cashews"],
            nutrient: "Zinc",
            phase: .follicular,
            dailyAmount: "7mg",
            icon: "drop",
            source: "NHS"
        ),
    ]

    // MARK: - Ovulation Phase Tips
    // Goal: support peak fertility, antioxidant protection, and liver function.

    private static let ovulationTips: [NutritionTip] = [
        NutritionTip(
            id: "ovu-nut-001",
            title: "Antioxidant-Rich Berries",
            description: "Antioxidants protect eggs from oxidative stress during the ovulatory process. Deeply coloured berries deliver anthocyanins and vitamin C to support cellular integrity.",
            foods: ["Blueberries", "Raspberries", "Blackberries", "Strawberries", "Pomegranate"],
            nutrient: "Antioxidants",
            phase: .ovulation,
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "ovu-nut-002",
            title: "Zinc for Ovulation Support",
            description: "Zinc is essential for the final maturation of eggs before ovulation. Oysters provide one of the highest dietary sources; pumpkin seeds are an excellent plant-based option.",
            foods: ["Oysters", "Pumpkin seeds", "Beef", "Cashews", "Chickpeas"],
            nutrient: "Zinc",
            phase: .ovulation,
            dailyAmount: "7mg",
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "ovu-nut-003",
            title: "High-Fibre Foods for Oestrogen Clearance",
            description: "Fibre binds excess oestrogen in the gut for excretion, preventing recirculation. This helps maintain the hormonal balance needed for a clean ovulatory surge.",
            foods: ["Lentils", "Oats", "Apples", "Pears", "Chia seeds", "Psyllium husk"],
            nutrient: "Fibre",
            phase: .ovulation,
            dailyAmount: "25–30g",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "ovu-nut-004",
            title: "Leafy Greens for Folate",
            description: "Folate is critical for DNA synthesis and cell division — processes that peak at ovulation. Dark leafy greens deliver folate alongside magnesium and iron.",
            foods: ["Spinach", "Rocket", "Watercress", "Asparagus", "Avocado"],
            nutrient: "Folate",
            phase: .ovulation,
            dailyAmount: "200mcg",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "ovu-nut-005",
            title: "Raw Vegetables and Light Meals",
            description: "Digestive capacity is high around ovulation. Light, fresh, nutrient-dense meals are easy to prepare and allow the body to allocate energy toward the ovulatory process.",
            foods: ["Cucumber", "Courgette", "Celery", "Fennel", "Radishes"],
            nutrient: "Hydration / Micronutrients",
            phase: .ovulation,
            icon: "nutrition",
            source: "NHS"
        ),
        NutritionTip(
            id: "ovu-nut-006",
            title: "Vitamin E for Egg Quality",
            description: "Vitamin E is a fat-soluble antioxidant that protects egg cell membranes from oxidative damage. Including vitamin E-rich foods around ovulation supports egg quality.",
            foods: ["Sunflower seeds", "Almonds", "Avocado", "Wheat germ oil", "Hazelnuts"],
            nutrient: "Vitamin E",
            phase: .ovulation,
            dailyAmount: "3mg",
            icon: "star-filled",
            source: "NHS"
        ),
        NutritionTip(
            id: "ovu-nut-007",
            title: "Stay Hydrated",
            description: "Cervical mucus quality improves with good hydration, supporting fertility. Aim for at least 1.5–2 litres of water and include water-rich foods throughout the day.",
            foods: ["Water", "Cucumber", "Watermelon", "Celery", "Herbal tea"],
            nutrient: "Hydration",
            phase: .ovulation,
            dailyAmount: "1.5–2L",
            icon: "drop",
            source: "NHS"
        ),
    ]

    // MARK: - Luteal Phase Tips
    // Goal: stabilise mood, manage PMS, support progesterone, reduce cravings.

    private static let lutealTips: [NutritionTip] = [
        NutritionTip(
            id: "lut-nut-001",
            title: "Complex Carbs to Combat Cravings",
            description: "Progesterone raises metabolic rate slightly, increasing appetite and carbohydrate cravings. Complex carbs satisfy these cravings while stabilising blood sugar and serotonin levels.",
            foods: ["Sweet potato", "Brown rice", "Oats", "Wholegrain pasta", "Butternut squash"],
            nutrient: "Complex Carbohydrates",
            phase: .luteal,
            icon: "bolt",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-002",
            title: "Calcium to Ease PMS Symptoms",
            description: "Low calcium is associated with greater PMS severity. Clinical studies show 1,200mg of calcium per day significantly reduces mood symptoms, bloating, and food cravings in the luteal phase.",
            foods: ["Dairy milk", "Fortified oat milk", "Sardines (with bones)", "Tofu", "Kale"],
            nutrient: "Calcium",
            phase: .luteal,
            dailyAmount: "700–1200mg",
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-003",
            title: "Tryptophan-Rich Foods for Serotonin",
            description: "Tryptophan is the precursor to serotonin, the mood-regulating neurotransmitter. Pairing tryptophan-rich proteins with complex carbs helps shuttle tryptophan across the blood-brain barrier.",
            foods: ["Turkey", "Chicken", "Bananas", "Eggs", "Pumpkin seeds", "Oats"],
            nutrient: "Tryptophan",
            phase: .luteal,
            icon: "book",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-004",
            title: "Magnesium to Reduce Bloating",
            description: "Magnesium deficiency is common and worsens PMS bloating, headaches, and mood swings. It also acts as a natural muscle relaxant, supporting sleep in the final days of the cycle.",
            foods: ["Dark chocolate (70%+)", "Spinach", "Avocado", "Almonds", "Black beans"],
            nutrient: "Magnesium",
            phase: .luteal,
            dailyAmount: "270–300mg",
            icon: "moon-stars",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-005",
            title: "Vitamin B6 for Mood Support",
            description: "Vitamin B6 is required for the synthesis of serotonin and dopamine. Research supports 80–100mg per day in reducing luteal-phase mood symptoms, though food sources are a safe first step.",
            foods: ["Chickpeas", "Salmon", "Potatoes", "Bananas", "Pistachios"],
            nutrient: "Vitamin B6",
            phase: .luteal,
            dailyAmount: "1.4mg (food) / up to 100mg supplement",
            icon: "heart",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-006",
            title: "Reduce Salt and Processed Foods",
            description: "Excess sodium promotes water retention and worsens luteal-phase bloating. Reducing processed and packaged foods in the second half of the cycle can meaningfully reduce puffiness.",
            foods: ["Fresh herbs", "Lemon juice", "Garlic", "Spices (unsalted)"],
            nutrient: "Sodium reduction",
            phase: .luteal,
            icon: "minus-circle",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-007",
            title: "Healthy Fats for Progesterone",
            description: "Cholesterol from healthy fats is the raw material for progesterone synthesis. Adequate fat intake during the luteal phase supports the hormone production needed to regulate the cycle.",
            foods: ["Avocado", "Olive oil", "Coconut oil", "Fatty fish", "Nut butters"],
            nutrient: "Healthy fats",
            phase: .luteal,
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "lut-nut-008",
            title: "Chasteberry Tea",
            description: "Vitex agnus-castus (chasteberry) has traditional and some clinical support for reducing PMS symptoms including breast tenderness, mood changes, and headaches when taken consistently.",
            foods: ["Chasteberry tea", "Vitex supplement (consult GP first)"],
            nutrient: "Vitex / Phytochemicals",
            phase: .luteal,
            icon: "leaf",
            source: "NHS"
        ),
    ]

    // MARK: - Pregnancy Trimester 1 Tips (Weeks 1–12)
    // Goal: support neural tube formation, manage nausea, establish key nutrients.

    private static let pregnancyTrimester1Tips: [NutritionTip] = [
        NutritionTip(
            id: "prg1-nut-001",
            title: "Folic Acid is Essential",
            description: "Folic acid taken before conception and during the first 12 weeks dramatically reduces the risk of neural tube defects such as spina bifida. A 400mcg supplement daily is recommended alongside dietary sources.",
            foods: ["Fortified cereals", "Spinach", "Asparagus", "Lentils", "Broccoli", "Avocado"],
            nutrient: "Folic Acid",
            isPregnancy: true,
            trimester: 1,
            dailyAmount: "400mcg supplement + dietary",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg1-nut-002",
            title: "Ginger for Morning Sickness",
            description: "Ginger has robust clinical evidence for reducing nausea and vomiting of pregnancy. Fresh ginger tea, ginger biscuits, or crystallised ginger can all provide relief without medication.",
            foods: ["Fresh ginger tea", "Ginger biscuits", "Crystallised ginger", "Ginger ale (natural)"],
            nutrient: "Gingerols",
            isPregnancy: true,
            trimester: 1,
            icon: "selfcare-relaxation",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg1-nut-003",
            title: "Small Frequent Meals",
            description: "An empty stomach worsens nausea. Eating small amounts every two to three hours keeps blood sugar stable and reduces the risk of pregnancy-related nausea and reflux.",
            foods: ["Plain crackers", "Rice cakes", "Toast", "Banana", "Mild soups"],
            nutrient: "Balanced macronutrients",
            isPregnancy: true,
            trimester: 1,
            icon: "clock",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg1-nut-004",
            title: "Vitamin B6 for Nausea Relief",
            description: "Vitamin B6 (pyridoxine) is recommended by NHS and ACOG as a first-line treatment for pregnancy nausea. Food sources combined with a supplement if advised by a midwife can make a significant difference.",
            foods: ["Bananas", "Potatoes", "Chickpeas", "Avocado"],
            nutrient: "Vitamin B6",
            isPregnancy: true,
            trimester: 1,
            dailyAmount: "10–25mg as directed",
            icon: "book",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg1-nut-005",
            title: "Iodine for Brain Development",
            description: "Iodine is critical for foetal thyroid hormone production, which drives early brain and nervous system development. Many women are mildly deficient; a pregnancy multivitamin with iodine fills the gap.",
            foods: ["Milk", "Yogurt", "White fish", "Eggs", "Seaweed (in moderation)"],
            nutrient: "Iodine",
            isPregnancy: true,
            trimester: 1,
            dailyAmount: "140mcg",
            icon: "book",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg1-nut-006",
            title: "Stay Hydrated to Reduce Fatigue",
            description: "Fatigue is common in the first trimester partly due to the blood volume expansion and the demands on kidneys. Sipping water and diluted juice throughout the day helps maintain energy levels.",
            foods: ["Water", "Diluted fruit juice", "Coconut water", "Mild herbal teas"],
            nutrient: "Hydration",
            isPregnancy: true,
            trimester: 1,
            dailyAmount: "1.5–2L",
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg1-nut-007",
            title: "Avoid High-Risk Foods",
            description: "Certain foods carry listeria, salmonella, or mercury risks that are particularly harmful in the first trimester. Avoid unpasteurised cheese, raw or undercooked eggs, liver, and high-mercury fish.",
            foods: ["Pasteurised cheese", "Well-cooked eggs", "Low-mercury fish (salmon, cod, trout)"],
            nutrient: "Food safety",
            isPregnancy: true,
            trimester: 1,
            icon: "warning",
            source: "NHS"
        ),
    ]

    // MARK: - Pregnancy Trimester 2 Tips (Weeks 13–27)
    // Goal: bone development, iron for expanding blood volume, optimal omega-3.

    private static let pregnancyTrimester2Tips: [NutritionTip] = [
        NutritionTip(
            id: "prg2-nut-001",
            title: "Calcium for Baby's Bones and Teeth",
            description: "The foetal skeleton develops rapidly in the second trimester. If dietary calcium is insufficient, the body draws from maternal bone stores — making adequate intake critical for both mother and baby.",
            foods: ["Milk", "Cheese", "Yogurt", "Fortified plant milk", "Tofu", "Almonds", "Kale"],
            nutrient: "Calcium",
            isPregnancy: true,
            trimester: 2,
            dailyAmount: "700–1000mg",
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg2-nut-002",
            title: "Vitamin D to Aid Calcium Absorption",
            description: "Vitamin D is required to absorb calcium from food. Sun exposure and diet alone are rarely sufficient during pregnancy; a 10mcg supplement is recommended by NHS throughout pregnancy.",
            foods: ["Oily fish", "Fortified cereals", "Egg yolks", "Fortified milk"],
            nutrient: "Vitamin D",
            isPregnancy: true,
            trimester: 2,
            dailyAmount: "10mcg supplement",
            icon: BloomIcons.sparkles,
            source: "NHS"
        ),
        NutritionTip(
            id: "prg2-nut-003",
            title: "Omega-3 for Brain Development",
            description: "DHA, an omega-3 fatty acid, is a primary structural component of the foetal brain and retina. Second trimester brain growth accelerates, making this a critical window for omega-3 intake.",
            foods: ["Salmon", "Trout", "Sardines", "Mackerel", "Walnuts", "Chia seeds"],
            nutrient: "DHA (Omega-3)",
            isPregnancy: true,
            trimester: 2,
            dailyAmount: "200mg DHA",
            icon: "book",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg2-nut-004",
            title: "Iron for Expanding Blood Volume",
            description: "Blood volume increases by up to 50% during pregnancy. Iron demand rises significantly from the second trimester onward to support red blood cell production and prevent anaemia.",
            foods: ["Red meat", "Spinach", "Lentils", "Tofu", "Fortified cereals", "Pumpkin seeds"],
            nutrient: "Iron",
            isPregnancy: true,
            trimester: 2,
            dailyAmount: "14.8–27mg",
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg2-nut-005",
            title: "Protein for Foetal Growth",
            description: "The second trimester marks rapid foetal growth. Protein is the primary building material for all foetal tissues. Aim for a variety of complete and incomplete protein sources across the day.",
            foods: ["Chicken", "Fish", "Eggs", "Greek yogurt", "Lentils", "Quinoa"],
            nutrient: "Protein",
            isPregnancy: true,
            trimester: 2,
            dailyAmount: "70–100g",
            icon: "figure-stand",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg2-nut-006",
            title: "Magnesium to Prevent Leg Cramps",
            description: "Leg cramps are a common second-trimester complaint linked to magnesium depletion. Increasing magnesium through food — and a supplement if directed by your midwife — can provide rapid relief.",
            foods: ["Almonds", "Spinach", "Pumpkin seeds", "Dark chocolate", "Avocado"],
            nutrient: "Magnesium",
            isPregnancy: true,
            trimester: 2,
            dailyAmount: "270–350mg",
            icon: "bolt",
            source: "NHS"
        ),
    ]

    // MARK: - Pregnancy Trimester 3 Tips (Weeks 28–40)
    // Goal: final foetal growth, labour preparation, continued maternal wellbeing.

    private static let pregnancyTrimester3Tips: [NutritionTip] = [
        NutritionTip(
            id: "prg3-nut-001",
            title: "Protein for Final Baby Growth",
            description: "The third trimester involves the fastest foetal weight gain. Protein supports brain myelination, muscle development, and organ maturation. Adequate protein also supports maternal tissue repair.",
            foods: ["Eggs", "Chicken", "Lentils", "Greek yogurt", "Salmon", "Cottage cheese"],
            nutrient: "Protein",
            isPregnancy: true,
            trimester: 3,
            dailyAmount: "70–100g",
            icon: "yoga",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg3-nut-002",
            title: "Dates for Labour Preparation",
            description: "Research shows consuming six dates per day from 36 weeks is associated with shorter labour, higher cervical dilation at admission, and reduced rates of induction. Dates are rich in natural sugars, fibre, and oxytocin-receptor-sensitising compounds.",
            foods: ["Medjool dates", "Deglet Noor dates"],
            nutrient: "Natural sugars / Tannins",
            isPregnancy: true,
            trimester: 3,
            dailyAmount: "6 dates from week 36",
            icon: "star-filled",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg3-nut-003",
            title: "Raspberry Leaf Tea",
            description: "Raspberry leaf tea is traditionally used from 32–36 weeks to tone the uterine muscle and prepare for labour. Always consult your midwife before starting — it is not recommended before 32 weeks.",
            foods: ["Raspberry leaf tea (from 32+ weeks, with midwife approval)"],
            nutrient: "Fragarine / Tannins",
            isPregnancy: true,
            trimester: 3,
            icon: "selfcare-relaxation",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg3-nut-004",
            title: "Stay Hydrated to Prevent Preterm Labour",
            description: "Dehydration can trigger uterine contractions and, in severe cases, contribute to preterm labour. Consistent fluid intake is one of the most important — and overlooked — priorities in late pregnancy.",
            foods: ["Water", "Coconut water", "Diluted fruit juice", "Mild herbal teas"],
            nutrient: "Hydration",
            isPregnancy: true,
            trimester: 3,
            dailyAmount: "2–2.5L",
            icon: "drop",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg3-nut-005",
            title: "Vitamin K for Newborn Health",
            description: "Vitamin K supports blood clotting. While newborns receive a vitamin K injection at birth, maternal vitamin K intake supports placental function and prepares the body for post-birth recovery.",
            foods: ["Spinach", "Kale", "Broccoli", "Brussels sprouts", "Fermented foods"],
            nutrient: "Vitamin K",
            isPregnancy: true,
            trimester: 3,
            dailyAmount: "90–120mcg",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg3-nut-006",
            title: "Iron to Prepare for Blood Loss at Birth",
            description: "Iron stores built during the third trimester protect against postpartum anaemia. Blood loss at delivery is normal; entering labour with good iron levels supports faster recovery.",
            foods: ["Red meat", "Lentils", "Fortified cereals", "Spinach", "Tofu"],
            nutrient: "Iron",
            isPregnancy: true,
            trimester: 3,
            dailyAmount: "27mg",
            icon: "heart-filled",
            source: "NHS"
        ),
        NutritionTip(
            id: "prg3-nut-007",
            title: "Small Meals to Manage Heartburn",
            description: "As the uterus grows, it pushes upward on the stomach, causing heartburn. Eating small portions frequently, staying upright after meals, and avoiding spicy or fatty foods significantly reduces discomfort.",
            foods: ["Plain yogurt", "Oats", "Banana", "Ginger tea", "Almonds"],
            nutrient: "Digestive comfort",
            isPregnancy: true,
            trimester: 3,
            icon: "flame",
            source: "NHS"
        ),
    ]

    // MARK: - General Tips (No Phase Specific)
    // Applicable across cycles and general healthy eating.

    private static let generalTips: [NutritionTip] = [
        NutritionTip(
            id: "gen-nut-001",
            title: "Eat the Rainbow",
            description: "A variety of colourful plant foods provides a broad spectrum of phytonutrients, antioxidants, and fibre. Aim for at least five different colours across your meals each day.",
            foods: ["Red pepper", "Carrots", "Blueberries", "Kale", "Sweetcorn", "Aubergine"],
            nutrient: "Phytonutrients",
            icon: "selfcare-creative",
            source: "NHS"
        ),
        NutritionTip(
            id: "gen-nut-002",
            title: "Prioritise Whole Foods",
            description: "Minimally processed whole foods retain the fibre, vitamins, and minerals that support hormonal health, energy, and mood across all phases of the cycle.",
            foods: ["Vegetables", "Fruit", "Whole grains", "Legumes", "Nuts", "Seeds"],
            nutrient: "Whole food nutrients",
            icon: "leaf",
            source: "NHS"
        ),
        NutritionTip(
            id: "gen-nut-003",
            title: "Hydration Throughout the Day",
            description: "Even mild dehydration impairs cognitive function and mood. Keeping a water bottle visible acts as a reminder to sip consistently rather than drinking large amounts infrequently.",
            foods: ["Water", "Herbal tea", "Infused water", "Cucumber water"],
            nutrient: "Hydration",
            dailyAmount: "1.5–2L",
            icon: "drop",
            source: "NHS"
        ),
    ]
}
