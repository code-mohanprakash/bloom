//
//  PregnancyWeekData.swift
//  BloomHer
//
//  Static content for all 40 weeks of pregnancy.
//
//  Medical sources:
//    - NHS Pregnancy Week-by-Week (www.nhs.uk)
//    - ACOG (American College of Obstetricians and Gynecologists) guidelines
//    - Mayo Clinic Pregnancy Reference
//
//  Size/weight figures use standard crown-to-rump (CRL) length for weeks 1-20
//  and crown-to-heel (CHL) length from week 20 onward, consistent with
//  clinical ultrasound reporting practice.
//
//  All content is informational only and does not constitute medical advice.
//  Users should always consult their healthcare provider for personalised care.
//

import Foundation

// MARK: - PregnancyWeekData

/// Static store for all 40 weeks of pregnancy content.
///
/// Usage:
/// ```swift
/// let week12 = PregnancyWeekData.content(for: 12)
/// let allWeeks = PregnancyWeekData.weeks
/// ```
enum PregnancyWeekData {

    // MARK: - All Weeks

    /// Complete ordered array of pregnancy week content, index 0 = week 1.
    static let weeks: [PregnancyWeekContent] = [

        // MARK: Week 1
        PregnancyWeekContent(
            week: 1,
            fruitComparison: "Poppy Seed",
            fruitEmoji: "🌱",
            babySizeCm: nil,
            babyWeightGrams: nil,
            babyDevelopment: [
                "Week 1 is counted from the first day of your last menstrual period — conception has not yet occurred.",
                "Your body is shedding its uterine lining and preparing to release a new egg.",
                "Hormone levels begin shifting in preparation for ovulation, which typically occurs around day 14."
            ],
            motherChanges: [
                "Menstrual bleeding and cramping are normal this week.",
                "Your uterus is completing its monthly reset, building a fresh lining that will soon support implantation."
            ],
            tips: [
                "Start taking a daily prenatal vitamin with at least 400 mcg of folic acid now — even before conception.",
                "Track your cycle start date so your healthcare provider can calculate your due date accurately."
            ],
            warningSignsToWatch: [
                "Extremely heavy bleeding (soaking more than one pad per hour) warrants medical attention.",
                "Severe pelvic pain outside of normal cramping should be evaluated."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 2
        PregnancyWeekContent(
            week: 2,
            fruitComparison: "Poppy Seed",
            fruitEmoji: "🌱",
            babySizeCm: nil,
            babyWeightGrams: nil,
            babyDevelopment: [
                "Ovulation typically occurs around day 14 of a 28-day cycle — the egg is released from a follicle.",
                "The egg is viable for fertilisation for approximately 12–24 hours after release.",
                "Sperm can survive in the reproductive tract for up to 5 days, making the fertile window roughly 5 days before to 1 day after ovulation."
            ],
            motherChanges: [
                "Oestrogen peaks around ovulation, which may cause a slight rise in basal body temperature and increased cervical mucus.",
                "Some women notice mild one-sided pelvic discomfort (mittelschmerz) at the time of ovulation."
            ],
            tips: [
                "If you are trying to conceive, this is your peak fertile window.",
                "Consider tracking cervical mucus or using an ovulation predictor kit to identify your most fertile days."
            ],
            warningSignsToWatch: [
                "Severe, sudden pelvic pain during ovulation should be evaluated to rule out ovarian cyst rupture."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 3
        PregnancyWeekContent(
            week: 3,
            fruitComparison: "Poppy Seed",
            fruitEmoji: "🌱",
            babySizeCm: 0.1,
            babyWeightGrams: nil,
            babyDevelopment: [
                "Fertilisation occurs when a sperm penetrates the egg, forming a single-celled zygote with 46 chromosomes.",
                "The zygote divides rapidly as it travels down the fallopian tube, becoming a morula (solid ball of cells), then a blastocyst.",
                "The blastocyst arrives in the uterus and begins the process of implantation into the uterine lining.",
                "The outer cells will form the placenta; the inner cell mass will become your baby."
            ],
            motherChanges: [
                "You are unlikely to notice any symptoms yet — implantation is just beginning.",
                "Human chorionic gonadotropin (hCG) production begins as the blastocyst embeds, signalling the body to maintain the uterine lining."
            ],
            tips: [
                "Continue taking your prenatal vitamin daily — folic acid is critical for neural tube formation which begins in week 3–4.",
                "Avoid alcohol, smoking, and unnecessary medications from this point forward."
            ],
            warningSignsToWatch: [
                "Any sharp, one-sided pain in the pelvic region warrants evaluation, as ectopic pregnancy can begin to manifest in early weeks."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 4
        PregnancyWeekContent(
            week: 4,
            fruitComparison: "Poppy Seed",
            fruitEmoji: "🌱",
            babySizeCm: 0.2,
            babyWeightGrams: nil,
            babyDevelopment: [
                "The embryo is about 0.2 cm — the size of a poppy seed — and implantation is now complete.",
                "The neural tube, which will become the brain and spinal cord, begins forming this week.",
                "Three primary germ layers — ectoderm, mesoderm, and endoderm — are established, each destined to form different organ systems.",
                "The placenta and umbilical cord are starting to develop to supply nutrients and oxygen."
            ],
            motherChanges: [
                "A home pregnancy test can now detect hCG in urine, often showing a positive result.",
                "Implantation bleeding — light spotting lasting 1–2 days — can occur and is normal.",
                "Breast tenderness, bloating, and fatigue may begin as progesterone rises."
            ],
            tips: [
                "Book your first antenatal appointment (booking appointment) with your GP or midwife as soon as possible.",
                "Stop alcohol entirely — no safe level has been established during pregnancy.",
                "Stay hydrated and begin establishing a regular sleep schedule."
            ],
            warningSignsToWatch: [
                "Heavy bleeding (heavier than a normal period) with cramping should be evaluated promptly.",
                "Severe, one-sided pain could indicate an ectopic pregnancy — seek immediate care."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 5
        PregnancyWeekContent(
            week: 5,
            fruitComparison: "Apple Seed",
            fruitEmoji: "🍏",
            babySizeCm: 0.4,
            babyWeightGrams: nil,
            babyDevelopment: [
                "The embryo is now about 0.4 cm and shaped like a small tadpole.",
                "The heart begins to form and will start beating this week — often visible on an early ultrasound.",
                "The neural tube continues to close; the brain, spinal cord, and nervous system are taking shape.",
                "Early limb buds — the precursors to arms and legs — are beginning to emerge."
            ],
            motherChanges: [
                "Morning sickness (nausea, with or without vomiting) may begin and can occur at any time of day.",
                "Heightened sense of smell is common and can trigger nausea.",
                "Frequent urination increases as blood volume rises and the kidneys work harder.",
                "Fatigue is often intense during the first trimester due to rising progesterone levels."
            ],
            tips: [
                "Eat small, frequent meals to manage nausea — an empty stomach often worsens symptoms.",
                "Ginger tea, ginger biscuits, or ginger capsules may help relieve nausea.",
                "Rest when you need to — first-trimester fatigue is real and your body is working hard."
            ],
            warningSignsToWatch: [
                "Inability to keep any fluids down for more than 24 hours (hyperemesis gravidarum) requires medical treatment.",
                "Any vaginal bleeding should be reported to your midwife or GP."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 6
        PregnancyWeekContent(
            week: 6,
            fruitComparison: "Lentil",
            fruitEmoji: "🟤",
            babySizeCm: 0.6,
            babyWeightGrams: nil,
            babyDevelopment: [
                "The embryo measures about 0.6 cm — roughly the size of a lentil.",
                "The heart is now beating at 100–160 beats per minute and can be detected via transvaginal ultrasound.",
                "Facial features are forming — dark spots mark where the eyes and nostrils will develop.",
                "Small buds that will become hands and feet are visible."
            ],
            motherChanges: [
                "Nausea and food aversions are typically at their most intense from weeks 6–10.",
                "Your uterus is growing — approximately the size of a plum — and you may notice pelvic pressure.",
                "Saliva production may increase (ptyalism), which can worsen nausea."
            ],
            tips: [
                "Cold foods often smell less strongly than hot foods, which can help with aversions.",
                "If prenatal vitamins worsen nausea, try taking them with food or at bedtime.",
                "Share your news with your partner or a close support person if you haven't already."
            ],
            warningSignsToWatch: [
                "Severe abdominal pain, particularly with shoulder tip pain, can indicate ectopic pregnancy — call emergency services.",
                "Heavy bleeding with clots should be evaluated urgently."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 7
        PregnancyWeekContent(
            week: 7,
            fruitComparison: "Blueberry",
            fruitEmoji: "🫐",
            babySizeCm: 1.0,
            babyWeightGrams: nil,
            babyDevelopment: [
                "The embryo is now about 1 cm — the size of a blueberry.",
                "The brain is growing rapidly, generating around 100 new nerve cells every minute.",
                "Arm and leg buds are growing longer and beginning to form paddle-shaped hand and foot plates.",
                "The digestive system, lungs, and liver are all developing simultaneously."
            ],
            motherChanges: [
                "Your blood volume is already increasing by up to 50% over the course of pregnancy.",
                "You may notice your veins becoming more prominent as circulation increases.",
                "Mood swings are common due to the significant hormonal fluctuations of early pregnancy."
            ],
            tips: [
                "Stay hydrated — aim for 8–10 glasses of water per day, which supports increased blood volume.",
                "Inform your GP about any prescription medications you take so they can assess safety in pregnancy.",
                "Gentle walking or prenatal yoga can help manage fatigue and mood."
            ],
            warningSignsToWatch: [
                "Fever above 38°C (100.4°F) during pregnancy should always be evaluated by a healthcare provider.",
                "Any significant reduction in breast tenderness after it has been present can sometimes indicate a pregnancy complication — mention it to your midwife."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 8
        PregnancyWeekContent(
            week: 8,
            fruitComparison: "Raspberry",
            fruitEmoji: "🫐",
            babySizeCm: 1.6,
            babyWeightGrams: 1.0,
            babyDevelopment: [
                "The embryo is about 1.6 cm and now officially referred to as a fetus from this week onward.",
                "All major organs — heart, brain, lungs, liver, kidneys — are present in rudimentary form.",
                "Fingers and toes are beginning to form, though they are still webbed.",
                "The fetus can make small, reflex movements, though these are not yet felt by the mother."
            ],
            motherChanges: [
                "Your uterus is now the size of a large orange and beginning to rise out of the pelvis.",
                "Constipation is common as progesterone relaxes the intestinal muscles, slowing digestion.",
                "Heartburn may begin as the same muscle-relaxing hormone affects the oesophageal sphincter."
            ],
            tips: [
                "Your dating scan (nuchal ultrasound) is typically scheduled between weeks 10–14 — book it now if you haven't.",
                "Increase dietary fibre and fluid intake to manage constipation.",
                "Avoid lying down immediately after meals to reduce heartburn."
            ],
            warningSignsToWatch: [
                "Persistent vomiting preventing adequate fluid intake (hyperemesis gravidarum) requires IV fluids and antiemetic treatment.",
                "Pain or burning on urination can indicate a urinary tract infection (UTI), which requires prompt treatment in pregnancy."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 9
        PregnancyWeekContent(
            week: 9,
            fruitComparison: "Cherry",
            fruitEmoji: "🍒",
            babySizeCm: 2.3,
            babyWeightGrams: 2.0,
            babyDevelopment: [
                "The fetus measures about 2.3 cm and the head is proportionally large relative to the body.",
                "External ears are forming and moving toward their final position on the sides of the head.",
                "Webbing between fingers is beginning to disappear as digits separate.",
                "The placenta is now taking over hormone production from the corpus luteum."
            ],
            motherChanges: [
                "hCG levels peak around weeks 8–10, which often coincides with the peak of morning sickness.",
                "You may notice your waistband feeling tighter even before a visible bump appears.",
                "Some women experience a heightened sense of taste (dysgeusia) — often described as metallic."
            ],
            tips: [
                "Chewing sugar-free gum or sucking on ice chips can help with the metallic taste sensation.",
                "Consider talking to your employer early about your maternity leave entitlements.",
                "Rest is not laziness — prioritise sleep and take naps when possible."
            ],
            warningSignsToWatch: [
                "Brown or pink spotting after intercourse can be normal due to cervical sensitivity, but bright red bleeding should be reported.",
                "Any pelvic pain or cramping that is not relieved by rest should be evaluated."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 10
        PregnancyWeekContent(
            week: 10,
            fruitComparison: "Strawberry",
            fruitEmoji: "🍓",
            babySizeCm: 3.1,
            babyWeightGrams: 4.0,
            babyDevelopment: [
                "The fetus is now 3.1 cm and all critical organ systems have formed — this marks the end of the most vulnerable period for birth defects.",
                "Fingernails and toenails are beginning to develop.",
                "The diaphragm is forming, and the fetus makes practice breathing movements.",
                "Bones and cartilage are starting to harden (ossification)."
            ],
            motherChanges: [
                "Your uterus is now approximately the size of a grapefruit.",
                "Visible veins on breasts and abdomen are normal and reflect increased blood flow.",
                "Round ligament pain — sharp, pulling sensations on one or both sides of the lower abdomen — may begin."
            ],
            tips: [
                "The NIPT (Non-Invasive Prenatal Test) and NT (Nuchal Translucency) scan can be performed from week 10 — discuss with your midwife or OB.",
                "Maternity clothing need not be purchased yet — waistband extenders and looser tops are often sufficient.",
                "Begin researching antenatal classes in your area — popular ones fill up quickly."
            ],
            warningSignsToWatch: [
                "Round ligament pain is sharp but brief; persistent or severe abdominal pain is not normal and requires evaluation.",
                "Unusual vaginal discharge (yellow, green, or foul-smelling) should be swabbed for infection."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 11
        PregnancyWeekContent(
            week: 11,
            fruitComparison: "Fig",
            fruitEmoji: "🍈",
            babySizeCm: 4.1,
            babyWeightGrams: 7.0,
            babyDevelopment: [
                "The fetus is now 4.1 cm and looks clearly human, with a large head accounting for half its body length.",
                "Tooth buds for all 20 primary teeth are forming beneath the gum line.",
                "The fetus can now swallow amniotic fluid and hiccup.",
                "External genitalia are developing, though sex determination by ultrasound is still several weeks away."
            ],
            motherChanges: [
                "Nausea often begins to ease slightly this week for many women, though it can persist into the second trimester.",
                "Hair and nail growth may speed up — a welcome side effect of pregnancy hormones.",
                "Skin changes such as darkening of the areolae and the appearance of the linea nigra (a dark line from navel to pubis) may begin."
            ],
            tips: [
                "Consider announcing your pregnancy publicly after your dating scan — many families choose to wait until after this confirmation.",
                "A pregnancy pillow can significantly improve sleep comfort as your body changes.",
                "Continue or start gentle exercise — swimming and walking are excellent low-impact options."
            ],
            warningSignsToWatch: [
                "Reduced fetal movement is not typically felt yet, but discuss any concerns about symptoms at your next appointment.",
                "Headaches that are severe, persistent, or accompanied by visual disturbance require prompt evaluation."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 12
        PregnancyWeekContent(
            week: 12,
            fruitComparison: "Lime",
            fruitEmoji: "🍋",
            babySizeCm: 5.4,
            babyWeightGrams: 14.0,
            babyDevelopment: [
                "The fetus measures about 5.4 cm — roughly the size of a lime.",
                "All major organs, muscles, limbs, and bones are in place; the remainder of pregnancy is primarily growth and maturation.",
                "Reflexes are developing: the fetus can open and close its fists and curl its toes.",
                "The kidneys are now producing urine, which is excreted into the amniotic fluid."
            ],
            motherChanges: [
                "Nausea and fatigue typically begin to ease for many women as hCG levels plateau.",
                "The risk of miscarriage drops significantly after 12 weeks, which is why many couples choose to announce around this time.",
                "Your uterus can now be felt just above the pubic bone."
            ],
            tips: [
                "Your dating scan (11–14 weeks) includes the nuchal translucency measurement for Down syndrome screening — ensure you have this booked.",
                "Begin moisturising the abdomen, hips, and breasts daily to help skin adapt to stretching.",
                "This is a good time to research and enrol in antenatal education classes."
            ],
            warningSignsToWatch: [
                "Any vaginal bleeding after 12 weeks should be reported immediately.",
                "Symptoms of preeclampsia — severe headache, visual changes, sudden swelling — should always be evaluated promptly."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 13
        PregnancyWeekContent(
            week: 13,
            fruitComparison: "Peach",
            fruitEmoji: "🍑",
            babySizeCm: 7.4,
            babyWeightGrams: 23.0,
            babyDevelopment: [
                "Welcome to the second trimester — the fetus is now 7.4 cm and growing rapidly.",
                "Fingerprints are forming on the fingertips — unique to this individual.",
                "The intestines, which temporarily developed in the umbilical cord, are migrating back into the abdomen.",
                "Vocal cords are beginning to form in the larynx."
            ],
            motherChanges: [
                "Energy levels often improve noticeably in the second trimester as the body adjusts to pregnancy.",
                "You may begin to show a small, firm bump as the uterus rises above the pubic bone.",
                "Skin on the abdomen may feel itchy as it begins to stretch."
            ],
            tips: [
                "Continue with a balanced diet rich in iron (lean meat, legumes, leafy greens) and calcium (dairy, fortified foods, tofu).",
                "Wear sunscreen daily — pregnancy hormones can increase skin sensitivity to UV radiation.",
                "Start thinking about your birth plan preferences, even informally, at this early stage."
            ],
            warningSignsToWatch: [
                "New or worsening pelvic girdle pain (PGP) should be assessed by a physiotherapist — early treatment significantly helps.",
                "Leg cramps and varicose veins may begin — compression stockings can help."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 14
        PregnancyWeekContent(
            week: 14,
            fruitComparison: "Lemon",
            fruitEmoji: "🍋",
            babySizeCm: 8.7,
            babyWeightGrams: 43.0,
            babyDevelopment: [
                "The fetus is now 8.7 cm and can make a wide range of facial expressions, including squinting and grimacing.",
                "Fine hair called lanugo begins to cover the body, helping to regulate temperature in the womb.",
                "The thyroid gland is now producing its own hormones.",
                "The liver is producing bile and the spleen is helping to produce red blood cells."
            ],
            motherChanges: [
                "Many women notice an increase in appetite as nausea subsides — focus on nutritious, energy-dense foods.",
                "Nasal congestion is common in pregnancy due to increased blood flow to mucous membranes.",
                "You may notice dark patches of skin on the face (melasma or 'pregnancy mask') — SPF 50 sunscreen helps prevent worsening."
            ],
            tips: [
                "Now is a good time to tell your employer about your pregnancy — maternity rights vary by country and early notice is beneficial.",
                "Omega-3 fatty acids (from oily fish, walnuts, or a supplement) support fetal brain development.",
                "Consider a pregnancy support belt if pelvic or back discomfort is increasing."
            ],
            warningSignsToWatch: [
                "Shortness of breath that is sudden, severe, or accompanied by chest pain requires immediate evaluation.",
                "Swelling in only one leg (rather than both) could indicate deep vein thrombosis (DVT) — seek same-day assessment."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 15
        PregnancyWeekContent(
            week: 15,
            fruitComparison: "Apple",
            fruitEmoji: "🍎",
            babySizeCm: 10.1,
            babyWeightGrams: 70.0,
            babyDevelopment: [
                "The fetus measures about 10 cm and is making active sucking and swallowing movements.",
                "Ears are nearly in their final position and the fetus can begin to hear muffled sounds from outside the womb.",
                "Eyebrows and eyelashes are beginning to grow.",
                "The skeletal system is continuing to harden from cartilage to bone."
            ],
            motherChanges: [
                "A visible bump is likely now or emerging soon — abdominal growth accelerates in the second trimester.",
                "Skin stretching may cause mild itching; moisturising twice daily helps.",
                "Round ligament pain is particularly common this week as the uterus grows rapidly."
            ],
            tips: [
                "The quadruple screen (maternal serum screening) for chromosomal conditions is offered between weeks 15–20 — discuss with your provider.",
                "Begin practicing side-sleeping (preferably on the left) as sleeping on the back may compress the vena cava from mid-pregnancy onward.",
                "Stay active — regular exercise improves sleep, mood, and reduces pregnancy complications."
            ],
            warningSignsToWatch: [
                "Itching that is severe, particularly on the palms and soles at night, could indicate obstetric cholestasis — report it.",
                "Any sudden, severe headache or visual disturbance warrants urgent evaluation."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 16
        PregnancyWeekContent(
            week: 16,
            fruitComparison: "Avocado",
            fruitEmoji: "🥑",
            babySizeCm: 11.6,
            babyWeightGrams: 100.0,
            babyDevelopment: [
                "At 11.6 cm and 100 g, the fetus is now about the size of an avocado.",
                "Eyes can make slow, side-to-side movements — the first hint of the visual tracking that will develop after birth.",
                "The fetus is becoming more active, though most mothers will not feel these movements for another 2–4 weeks.",
                "Toenails are beginning to grow and the skin, while thin, is becoming more organised."
            ],
            motherChanges: [
                "Many mothers feel a distinct energy boost this week — harness it for planning and preparation.",
                "Backache may begin as the growing uterus shifts your centre of gravity.",
                "Increased vaginal discharge (leukorrhea) is normal and protective of the birth canal."
            ],
            tips: [
                "Begin investing in maternity clothes — this is the week most women find their regular clothes consistently uncomfortable.",
                "Practice good posture and consider a maternity support band for lower back relief.",
                "Research your hospital or birth centre and consider scheduling a tour."
            ],
            warningSignsToWatch: [
                "Watery fluid leaking from the vagina (distinct from normal discharge) could indicate amniotic fluid loss — seek immediate assessment.",
                "Sudden reduction in or absence of symptoms does not necessarily indicate a problem, but can be discussed with your midwife."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 17
        PregnancyWeekContent(
            week: 17,
            fruitComparison: "Pear",
            fruitEmoji: "🍐",
            babySizeCm: 13.0,
            babyWeightGrams: 140.0,
            babyDevelopment: [
                "The fetus is now 13 cm and its skeleton is rapidly changing from soft cartilage to hardened bone.",
                "The umbilical cord is growing thicker and stronger to handle increasing blood flow.",
                "The fetus has developed a sleep-wake cycle, though it sleeps most of the time.",
                "Brown adipose tissue (fat) is beginning to form — this fat will help regulate body temperature at birth."
            ],
            motherChanges: [
                "Braxton Hicks contractions (irregular, painless tightenings of the uterus) may begin this week or in coming weeks.",
                "Haemorrhoids may develop due to increased pelvic pressure and constipation — fibre and hydration help.",
                "Dizziness can occur when standing up quickly (orthostatic hypotension) — rise slowly from sitting or lying positions."
            ],
            tips: [
                "Keep track of any Braxton Hicks contractions — they are irregular and painless. Regular, painful contractions before 37 weeks require immediate medical attention.",
                "Discuss cord blood banking with your partner and healthcare provider if this is of interest.",
                "Begin researching paediatric care providers (GPs and health visitors) for after the birth."
            ],
            warningSignsToWatch: [
                "Regular uterine contractions (more than 4 in an hour) before 37 weeks could indicate preterm labour — call your midwife.",
                "A fall or any trauma to the abdomen should be evaluated, even if you feel fine."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 18
        PregnancyWeekContent(
            week: 18,
            fruitComparison: "Bell Pepper",
            fruitEmoji: "🫑",
            babySizeCm: 14.2,
            babyWeightGrams: 190.0,
            babyDevelopment: [
                "At 14.2 cm, the fetus is now around the size of a bell pepper.",
                "Myelin — the protective sheath around nerve fibres — begins forming, a process that continues for years after birth.",
                "The fetus can hear clearly now, reacting to loud sounds with startled movements.",
                "Yawning, hiccupping, and stretching are now regular activities."
            ],
            motherChanges: [
                "First-time mothers typically feel fetal movements (quickening) between weeks 18–22 — often described as gentle flutters or bubbles.",
                "Your uterus is now level with your navel.",
                "Lower back pain may intensify as your lumbar curve deepens to compensate for your growing belly."
            ],
            tips: [
                "The anatomy scan (anomaly scan) is typically scheduled between weeks 18–22 — this detailed ultrasound checks fetal growth and anatomy.",
                "Begin sleeping with a pillow between your knees to support spinal alignment.",
                "Talk, read, or play music to your baby — they can hear you."
            ],
            warningSignsToWatch: [
                "If you have not felt any fetal movement by week 22, inform your midwife.",
                "Persistent rib pain or upper right abdominal pain can indicate liver problems — report promptly."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 19
        PregnancyWeekContent(
            week: 19,
            fruitComparison: "Mango",
            fruitEmoji: "🥭",
            babySizeCm: 15.3,
            babyWeightGrams: 240.0,
            babyDevelopment: [
                "The fetus measures about 15.3 cm and is covered in vernix caseosa — a white, waxy coating that protects the skin from amniotic fluid.",
                "Sensory development is at a peak: the brain is designating specialised areas for smell, taste, hearing, vision, and touch.",
                "In female fetuses, the uterus is fully formed and the vaginal canal is developing.",
                "In male fetuses, the testes have begun descending from the abdomen."
            ],
            motherChanges: [
                "You may notice your belly button beginning to flatten or protrude outward.",
                "Leg cramps, particularly at night, are common — ensure adequate calcium and magnesium intake.",
                "Varicose veins in the legs are more likely if you are on your feet for long periods — compression socks help significantly."
            ],
            tips: [
                "Attend the anomaly scan appointment; ask the sonographer about placenta position and, if desired, baby's sex.",
                "Calf stretches before bed and maintaining hydration can help prevent overnight leg cramps.",
                "Begin researching infant feeding options (breastfeeding, formula) and consider a breastfeeding support class."
            ],
            warningSignsToWatch: [
                "Sudden, severe heartburn accompanied by nausea and upper abdominal pain — particularly after week 20 — warrants evaluation for HELLP syndrome.",
                "Significant swelling in the face or hands alongside headache could be an early sign of preeclampsia."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 20
        PregnancyWeekContent(
            week: 20,
            fruitComparison: "Banana",
            fruitEmoji: "🍌",
            babySizeCm: 25.0,
            babyWeightGrams: 300.0,
            babyDevelopment: [
                "Halfway! The fetus is now measured crown-to-heel at approximately 25 cm — the length of a banana.",
                "The anatomy scan this week checks all major organs, brain structure, spine, limbs, and placenta position.",
                "The fetus is swallowing amniotic fluid regularly, which aids in developing the digestive system.",
                "Movement is becoming more coordinated and purposeful — kicks and rolls are increasingly noticeable."
            ],
            motherChanges: [
                "Your uterus now reaches your navel — a classic midway milestone.",
                "Shortness of breath may begin as the uterus starts to push up against the diaphragm.",
                "Skin pigmentation changes (linea nigra, melasma) are at their most visible."
            ],
            tips: [
                "Attend your anomaly scan — this is the most comprehensive assessment of fetal anatomy during pregnancy.",
                "Begin a birth plan document, noting your preferences for pain relief, labour environment, and delivery preferences.",
                "Register for an antenatal class if you haven't already — classes fill up quickly."
            ],
            warningSignsToWatch: [
                "If the anomaly scan identifies placenta praevia (placenta covering the cervix), follow your provider's guidance on activity restrictions.",
                "Unusual fetal movement patterns (a sudden flurry followed by silence) should be discussed with your midwife."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 21
        PregnancyWeekContent(
            week: 21,
            fruitComparison: "Carrot",
            fruitEmoji: "🥕",
            babySizeCm: 26.7,
            babyWeightGrams: 360.0,
            babyDevelopment: [
                "The fetus is now 26.7 cm and its limb proportions are becoming more balanced relative to the head.",
                "Taste buds are fully developed and the fetus can taste the flavours of whatever you eat via amniotic fluid.",
                "The sucking reflex is strong — ultrasound may show the fetus sucking its thumb.",
                "Eyebrows and eyelids are now well developed."
            ],
            motherChanges: [
                "Fetal movements should now be clearly felt and will become more regular as the weeks progress.",
                "You may notice increased sweating as your metabolism and blood volume are elevated.",
                "Oedema (swelling) in the ankles and feet is common, especially toward the end of the day."
            ],
            tips: [
                "Eat a varied diet — research suggests that flavours experienced in utero can influence food preferences in infancy.",
                "Elevate your feet when resting to help reduce swelling.",
                "Begin looking into maternity or parental leave policies at your workplace."
            ],
            warningSignsToWatch: [
                "Sudden or severe swelling in the face, hands, or one leg requires same-day assessment.",
                "Fetal movements that feel dramatically reduced from your usual pattern should be reported to your midwife immediately."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 22
        PregnancyWeekContent(
            week: 22,
            fruitComparison: "Coconut",
            fruitEmoji: "🥥",
            babySizeCm: 27.8,
            babyWeightGrams: 430.0,
            babyDevelopment: [
                "At 27.8 cm, the fetus is gaining weight steadily and fat deposits are becoming more substantial.",
                "Grip strength is developing — the fetus can grip the umbilical cord.",
                "The inner ear structures are fully formed, allowing the fetus to have a sense of balance.",
                "At this gestation, a baby born very prematurely has a small but real chance of survival with intensive neonatal care."
            ],
            motherChanges: [
                "Back ache is nearly universal at this stage — swimming, physiotherapy, and a supportive mattress all help.",
                "You may notice the fundal height (distance from pubic bone to top of uterus) is roughly equal to your week of pregnancy in centimetres.",
                "Pregnancy brain (mild forgetfulness and difficulty concentrating) is real and hormone-mediated."
            ],
            tips: [
                "Begin planning the nursery or baby's sleep space — lead times on furniture and decorating can be longer than expected.",
                "Discuss fetal kick counting with your midwife — establishing your baby's normal movement pattern is a valuable safety habit.",
                "Keep a pregnancy journal if you enjoy writing — these memories are precious."
            ],
            warningSignsToWatch: [
                "Any sudden gush of fluid from the vagina should be assessed immediately for possible premature rupture of membranes (PROM).",
                "A feeling of pressure or heaviness in the pelvis could indicate cervical incompetence in high-risk women — discuss with your provider."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 23
        PregnancyWeekContent(
            week: 23,
            fruitComparison: "Grapefruit",
            fruitEmoji: "🍊",
            babySizeCm: 28.9,
            babyWeightGrams: 501.0,
            babyDevelopment: [
                "The fetus now weighs over 500 g — a significant milestone — and measures 28.9 cm.",
                "The lungs are developing surfactant, the substance that prevents the air sacs from collapsing after birth.",
                "The fetus is forming a sleep-wake cycle that may not align with yours, so night-time kicks are common.",
                "Blood vessels in the lungs are proliferating in preparation for breathing air after birth."
            ],
            motherChanges: [
                "You may feel the uterus contracting intermittently (Braxton Hicks) as it rehearses for labour.",
                "Skin stretching may cause stretchmarks to begin appearing on the abdomen, breasts, and thighs — these are a normal part of pregnancy.",
                "Increased pigmentation around the areolae prepares the breast for breastfeeding."
            ],
            tips: [
                "If you plan to breastfeed, consider attending a breastfeeding preparation class or watching videos from a certified lactation consultant.",
                "Continue with gentle exercise — prenatal Pilates is particularly effective for back pain and pelvic floor strength.",
                "Ask your midwife about the MFAU (Maternity Fetal Assessment Unit) process — so you know when and how to report concerns."
            ],
            warningSignsToWatch: [
                "Signs of preterm labour: regular painful contractions, lower back pain, pelvic pressure, or watery discharge before 37 weeks.",
                "Decreased fetal movement should always be reported the same day — do not wait until your next appointment."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 24
        PregnancyWeekContent(
            week: 24,
            fruitComparison: "Corn",
            fruitEmoji: "🌽",
            babySizeCm: 30.0,
            babyWeightGrams: 600.0,
            babyDevelopment: [
                "At 30 cm and 600 g, the fetus has reached the point of viability — a baby born at this gestation can survive outside the womb with intensive neonatal support.",
                "The face is now fully formed with clearly distinguishable features.",
                "The fetus has periods of rapid eye movement (REM) sleep — the phase associated with dreaming.",
                "Taste receptors on the tongue are functioning and the fetus actively samples the amniotic fluid."
            ],
            motherChanges: [
                "Gestational diabetes screening (glucose challenge or OGTT) is typically offered between weeks 24–28.",
                "Heartburn is very common as the uterus displaces the stomach upward — propped sleeping and antacids can help.",
                "Symphysis pubis dysfunction (SPD) — pain at the front of the pelvis — may begin or worsen."
            ],
            tips: [
                "Attend your glucose screening appointment — gestational diabetes is manageable but requires early identification.",
                "Avoid spicy, fatty, and carbonated foods to manage heartburn.",
                "Practice the positions and breathing techniques you have learned in antenatal class."
            ],
            warningSignsToWatch: [
                "Excessive thirst, frequent urination, and fatigue could indicate gestational diabetes — report these between screenings.",
                "Blurred vision or seeing spots (floaters) should prompt immediate evaluation."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 25
        PregnancyWeekContent(
            week: 25,
            fruitComparison: "Cauliflower",
            fruitEmoji: "🥦",
            babySizeCm: 34.6,
            babyWeightGrams: 660.0,
            babyDevelopment: [
                "The fetus is 34.6 cm and the hands and fingers are becoming increasingly dexterous.",
                "The nostrils, previously plugged with mucus, are beginning to open.",
                "Capillaries are forming just beneath the skin, giving it a reddish, translucent appearance.",
                "The spinal cord is continuing to develop and strengthen."
            ],
            motherChanges: [
                "You may notice your navel popping out as the uterus pushes forward.",
                "Carpal tunnel syndrome — tingling and numbness in the hands — is common due to fluid retention compressing the median nerve.",
                "Restless leg syndrome may affect sleep — regular gentle exercise and magnesium may help."
            ],
            tips: [
                "Wrist splints worn overnight can significantly relieve pregnancy-related carpal tunnel symptoms.",
                "Magnesium-rich foods (nuts, seeds, dark leafy greens) or a magnesium supplement (with your provider's approval) may help restless legs and cramps.",
                "Book any remaining antenatal appointments to ensure your schedule is complete."
            ],
            warningSignsToWatch: [
                "Persistent severe headache, especially with visual changes or swelling, should be evaluated for preeclampsia.",
                "Fetal movement counts below your established normal pattern require same-day reporting."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 26
        PregnancyWeekContent(
            week: 26,
            fruitComparison: "Kale",
            fruitEmoji: "🥬",
            babySizeCm: 35.6,
            babyWeightGrams: 760.0,
            babyDevelopment: [
                "The fetus is 35.6 cm and the eyes — which have been fused shut — are beginning to open for the first time.",
                "The retina is developing the light-sensing cells required for vision.",
                "Lung development is accelerating and the lungs are beginning to produce surfactant in greater quantities.",
                "Brain wave activity patterns now include those associated with active and quiet states."
            ],
            motherChanges: [
                "Braxton Hicks contractions may be occurring more frequently and more noticeably.",
                "You may begin leaking colostrum (early breast milk) from the nipples — this is normal and can be managed with breast pads.",
                "Upper back and neck discomfort is common as your posture adapts to your changing centre of gravity."
            ],
            tips: [
                "Begin writing or finalising your birth plan and discuss it with your midwife or OB.",
                "If you are Rh-negative, an anti-D injection is typically offered at 28 weeks — ensure this is on your schedule.",
                "Consider a pregnancy massage from a qualified prenatal massage therapist for muscle tension relief."
            ],
            warningSignsToWatch: [
                "Persistent itching, especially of the palms and soles, could indicate obstetric cholestasis (intrahepatic cholestasis of pregnancy).",
                "Signs of preterm labour should prompt immediate hospital contact."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 27 — End of Second Trimester
        PregnancyWeekContent(
            week: 27,
            fruitComparison: "Iceberg Lettuce",
            fruitEmoji: "🥬",
            babySizeCm: 36.6,
            babyWeightGrams: 875.0,
            babyDevelopment: [
                "At 36.6 cm and nearly 875 g, the fetus is completing the second trimester.",
                "Brain tissue is developing rapidly — the characteristic folds and grooves of the cerebral cortex are beginning to form.",
                "The fetus can now suck its thumb, blink, and cough.",
                "Fat stores are accumulating, rounding out the body and giving the skin a less wrinkled appearance."
            ],
            motherChanges: [
                "Haemorrhoids may be causing discomfort — topical treatments and dietary fibre are first-line management.",
                "Your fundal height is approaching the rib cage, which can cause shortness of breath and rib discomfort.",
                "Increased emotional sensitivity is normal as you process the upcoming birth and parenthood transition."
            ],
            tips: [
                "Congratulations on completing the second trimester — the final stretch begins next week.",
                "Arrange any remaining childcare logistics and ensure your workplace handover plan is underway.",
                "Begin assembling or purchasing the essentials for your hospital bag (see the Checklist tab)."
            ],
            warningSignsToWatch: [
                "Any bleeding at this stage is abnormal and requires immediate evaluation.",
                "Sudden severe headache, visual disturbance, or rapidly worsening oedema are signs of preeclampsia — seek emergency care."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 28 — Third Trimester Begins
        PregnancyWeekContent(
            week: 28,
            fruitComparison: "Eggplant",
            fruitEmoji: "🍆",
            babySizeCm: 37.6,
            babyWeightGrams: 1005.0,
            babyDevelopment: [
                "Welcome to the third trimester. The fetus now weighs over 1 kg and measures 37.6 cm.",
                "The eyes are now fully open and the fetus can perceive the difference between light and dark.",
                "REM sleep is well established and the fetus dreams.",
                "The rate of brain growth is remarkable — the brain will triple in weight during the third trimester."
            ],
            motherChanges: [
                "You may feel the baby change position — many babies begin to move into a head-down (cephalic) position around now.",
                "Pelvic pressure is increasing as the baby grows and descends.",
                "Insomnia is extremely common in the third trimester — a pregnancy pillow and a consistent bedtime routine help."
            ],
            tips: [
                "Begin kick counting: note 10 movements in a 2-hour window. If you cannot reach 10 movements, contact your midwife.",
                "Anti-D injection for Rh-negative mothers is given at 28 weeks — attend this appointment.",
                "Begin packing your hospital bag in earnest this week."
            ],
            warningSignsToWatch: [
                "Preeclampsia risk increases in the third trimester — report any headache, visual symptoms, or upper abdominal pain promptly.",
                "A reduction in fetal movement from your normal pattern should always be reported the same day."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 29
        PregnancyWeekContent(
            week: 29,
            fruitComparison: "Butternut Squash",
            fruitEmoji: "🎃",
            babySizeCm: 38.6,
            babyWeightGrams: 1153.0,
            babyDevelopment: [
                "The fetus is 38.6 cm and gaining approximately 200 g per week from now until birth.",
                "Muscle tone is increasing and movements are becoming stronger and more forceful.",
                "The adrenal glands are producing DHEA, a hormone that will be converted to oestrogen by the placenta.",
                "Lanugo (the fine body hair) is gradually beginning to shed from the face."
            ],
            motherChanges: [
                "Heartburn and indigestion are typically at their worst now as the uterus reaches its highest point under the ribcage.",
                "Sleep is increasingly disrupted by frequency of urination, discomfort, and fetal movements.",
                "Ankle and foot swelling tends to be most pronounced at the end of the day."
            ],
            tips: [
                "Sleep on your left side — this optimises blood flow to the placenta and reduces pressure on the vena cava.",
                "Eat small meals every 2–3 hours rather than large meals to reduce heartburn and maintain stable blood sugar.",
                "Look into newborn care classes offered by your hospital or community health services."
            ],
            warningSignsToWatch: [
                "Sudden onset of breathlessness or chest pain requires urgent evaluation.",
                "Any signs of preterm labour — regular contractions, lower back pain, pelvic pressure — at this gestation require immediate hospital attendance."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 30
        PregnancyWeekContent(
            week: 30,
            fruitComparison: "Cabbage",
            fruitEmoji: "🥬",
            babySizeCm: 39.9,
            babyWeightGrams: 1319.0,
            babyDevelopment: [
                "The fetus weighs approximately 1.3 kg and measures 39.9 cm.",
                "The bone marrow has fully taken over red blood cell production from the liver and spleen.",
                "The fetus is now practicing breathing movements for approximately 30% of the time, inhaling amniotic fluid.",
                "Brain development continues rapidly — the cerebral cortex is developing its characteristic wrinkled surface area."
            ],
            motherChanges: [
                "Braxton Hicks contractions may be frequent and strong — they should be irregular and resolve with position change or hydration.",
                "Your centre of gravity has shifted significantly — take extra care on uneven surfaces and stairs.",
                "Colostrum production is increasing and occasional leakage is normal."
            ],
            tips: [
                "Begin discussing your postpartum support plan with your partner and family — who will help in the first weeks?",
                "Consider preparing and freezing meals now to build a postpartum freezer stock.",
                "Attend any remaining antenatal appointments and ensure your Group B Strep test is scheduled if appropriate for your region."
            ],
            warningSignsToWatch: [
                "Consistent contractions (every 5–7 minutes) before 37 weeks — even if not painful — require immediate evaluation.",
                "Sudden or severe abdominal pain at any point should prompt emergency contact."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 31
        PregnancyWeekContent(
            week: 31,
            fruitComparison: "Coconut",
            fruitEmoji: "🥥",
            babySizeCm: 41.1,
            babyWeightGrams: 1502.0,
            babyDevelopment: [
                "The fetus now weighs approximately 1.5 kg — gaining weight at its fastest rate yet.",
                "All five senses are now operational: the fetus can see, hear, smell, taste, and feel.",
                "The majority of lanugo has shed and the skin is less wrinkled as fat accumulates beneath it.",
                "The fetus is capable of turning its head from side to side."
            ],
            motherChanges: [
                "Pelvic girdle pain and pubic symphysis pain may intensify as pelvic ligaments soften in preparation for birth.",
                "Frequent trips to the bathroom at night are disrupting sleep for most mothers at this stage.",
                "Shortness of breath is often at its worst between weeks 31–36, before the baby descends (engages) in late pregnancy."
            ],
            tips: [
                "A 'birth preferences' or birth plan document helps communicate your wishes clearly to your care team — complete and share it by 36 weeks.",
                "Pelvic floor exercises (Kegel exercises) done regularly throughout pregnancy support recovery after birth.",
                "Begin reading reviews and researching newborn car seats, prams, and essential baby equipment if not yet done."
            ],
            warningSignsToWatch: [
                "Severe or constant rib pain should be evaluated — it can sometimes indicate liver inflammation associated with preeclampsia.",
                "Fetal movement changes require same-day reporting — do not rely on time-of-day reasoning to dismiss concerns."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 32
        PregnancyWeekContent(
            week: 32,
            fruitComparison: "Coconut",
            fruitEmoji: "🥥",
            babySizeCm: 42.4,
            babyWeightGrams: 1702.0,
            babyDevelopment: [
                "At 42.4 cm and approximately 1.7 kg, the fetus is quickly filling the uterine space.",
                "Most babies are now in a head-down position — your midwife will monitor this at appointments.",
                "Toenails and fingernails are fully grown and may need trimming shortly after birth.",
                "The lungs are well developed and a baby born at 32 weeks has an excellent survival rate with appropriate neonatal support."
            ],
            motherChanges: [
                "You may notice a significant increase in discharge — your body is producing more mucus to protect the birth canal.",
                "Leaking urine when laughing, sneezing, or coughing (stress incontinence) is very common — Kegel exercises help.",
                "Stretch marks may appear or deepen as the skin reaches its maximum stretch."
            ],
            tips: [
                "Your hospital bag should be packed and ready by week 36 at the latest — start assembling it this week.",
                "Discuss cord clamping preferences with your birth team — delayed cord clamping is recommended by ACOG and NICE.",
                "If your baby is not in a head-down position by week 36, your provider will discuss external cephalic version (ECV) options."
            ],
            warningSignsToWatch: [
                "Leaking clear fluid from the vagina (not normal discharge) should be assessed for rupture of membranes.",
                "Intense itching of the skin, particularly palms and soles, requires a blood test to rule out obstetric cholestasis."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 33
        PregnancyWeekContent(
            week: 33,
            fruitComparison: "Pineapple",
            fruitEmoji: "🍍",
            babySizeCm: 43.7,
            babyWeightGrams: 1918.0,
            babyDevelopment: [
                "The fetus weighs approximately 1.9 kg and the skull, though hardening, remains flexible to allow passage through the birth canal.",
                "The immune system is maturing and the fetus receives antibodies through the placenta in preparation for life outside the womb.",
                "Rapid eye movement (REM) sleep is well established — the brain is actively processing and developing.",
                "The pupils can constrict and dilate in response to light."
            ],
            motherChanges: [
                "Fatigue returns for many mothers in the third trimester as the physical demands of carrying a larger baby increase.",
                "The baby may 'drop' (engage) this week or in coming weeks — you may find breathing easier but pelvic pressure increased.",
                "Swelling of the feet, ankles, and hands is common but should not be asymmetrical or sudden."
            ],
            tips: [
                "Plan for the first few days at home — have essentials (nappies, wipes, feeding supplies) ready and accessible.",
                "Consider a 'babymoon' or quiet weekend away if you feel well enough — it becomes much harder to travel once baby arrives.",
                "Review your employer's parental leave policy and ensure all paperwork is submitted."
            ],
            warningSignsToWatch: [
                "Sudden or one-sided facial, hand, or foot swelling combined with headache or visual changes — seek emergency care.",
                "Any significant change in your baby's movement pattern requires same-day contact with your midwife."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 34
        PregnancyWeekContent(
            week: 34,
            fruitComparison: "Cantaloupe",
            fruitEmoji: "🍈",
            babySizeCm: 45.0,
            babyWeightGrams: 2146.0,
            babyDevelopment: [
                "At 45 cm and over 2.1 kg, the fetus's organs are nearly all mature enough to function independently.",
                "The lungs are almost fully developed — a baby born at 34 weeks typically requires only brief respiratory support.",
                "Vernix caseosa (the protective white coating) is becoming thicker as the birth approaches.",
                "The fetus is storing iron, calcium, and other minerals that will sustain it during the first weeks of life."
            ],
            motherChanges: [
                "Pelvic floor and lower back aches are near their maximum intensity — delivery will bring significant relief.",
                "Braxton Hicks contractions may be mistaken for labour — the key distinction is regularity and progression.",
                "Lightning crotch — sharp, shooting pain in the vagina or pelvis — is caused by nerve compression from the baby's position."
            ],
            tips: [
                "Choose and contact your paediatric provider (GP or health visitor) before the birth so the registration process is already underway.",
                "Install and have your infant car seat inspected by a qualified technician before the birth.",
                "Begin perineal massage (with your provider's guidance) — research supports its role in reducing perineal tearing at birth."
            ],
            warningSignsToWatch: [
                "Group B Streptococcus (GBS) screening, if offered in your region, is typically done at 35–37 weeks — ensure it is on your schedule.",
                "Regular, painful contractions before 37 weeks require immediate hospital attendance."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 35
        PregnancyWeekContent(
            week: 35,
            fruitComparison: "Honeydew Melon",
            fruitEmoji: "🍈",
            babySizeCm: 46.2,
            babyWeightGrams: 2383.0,
            babyDevelopment: [
                "The fetus is 46.2 cm and the kidneys are now fully mature.",
                "The liver can now process some waste products — it will take over fully from the placenta after birth.",
                "The fetus may have moved into a final position — most are head-down by this week.",
                "Fat continues to accumulate, giving the baby the rounded, chubby appearance typical of newborns."
            ],
            motherChanges: [
                "Your uterus is approximately 1,000 times its pre-pregnancy volume — the largest it will ever be.",
                "Engagement (the baby's head moving into the pelvis) may cause a noticeable drop in the bump profile and relief of rib pressure.",
                "Trouble sleeping, needing to urinate every 1–2 hours at night, is very common and will not harm you or the baby."
            ],
            tips: [
                "Ensure your hospital bag is completely packed — some babies arrive before 37 weeks.",
                "Write down your birth plan and include copies in your hospital bag, your notes, and with your birth partner.",
                "Learn the signs of labour: regular contractions, a 'show' (mucus plug), and waters breaking."
            ],
            warningSignsToWatch: [
                "A greenish or brown tinge to amniotic fluid (meconium) requires immediate hospital attendance.",
                "Any gush or steady trickle of fluid from the vagina should be assessed the same day."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 36
        PregnancyWeekContent(
            week: 36,
            fruitComparison: "Melon",
            fruitEmoji: "🍈",
            babySizeCm: 47.4,
            babyWeightGrams: 2622.0,
            babyDevelopment: [
                "At 47.4 cm and 2.6 kg, the fetus is considered 'late preterm' from this week — organs are functional but development is still ongoing.",
                "Most lanugo has shed and the vernix coating is beginning to thin.",
                "The fetus's head is pressing against the cervix, which begins the process of ripening (softening and effacing).",
                "Skull bones are flexible and overlapping slightly to allow passage through the birth canal — this is entirely normal."
            ],
            motherChanges: [
                "Nesting instinct — a powerful urge to clean, organise, and prepare the home — often peaks at this stage.",
                "Increased Braxton Hicks contractions are common and normal as the body prepares for labour.",
                "Mucus plug discharge ('show') may occur any time from now — labour does not always immediately follow."
            ],
            tips: [
                "Prepare and freeze a batch of nutritious meals for the postpartum period — this is one of the most practical things you can do.",
                "Discuss your Group B Strep result with your provider and what it means for your birth plan.",
                "Finalise all newborn administrative needs: registering the birth, paternity leave, baby name shortlist."
            ],
            warningSignsToWatch: [
                "Decreased fetal movement from your established pattern requires immediate contact with your midwife or hospital.",
                "Any signs of labour before 37 weeks should prompt immediate hospital attendance."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 37 — Early Term
        PregnancyWeekContent(
            week: 37,
            fruitComparison: "Winter Melon",
            fruitEmoji: "🍈",
            babySizeCm: 48.6,
            babyWeightGrams: 2859.0,
            babyDevelopment: [
                "The fetus is now considered early term (37–38 weeks) — all major systems are mature but brain development is still ongoing.",
                "The baby is gaining approximately 14 g of fat per day.",
                "Practice breathing movements occur for approximately 40% of the time.",
                "Meconium (the baby's first stool) is accumulating in the intestines, ready to be passed after birth."
            ],
            motherChanges: [
                "Cervical changes (effacement and early dilation) may begin without any noticeable contractions.",
                "Pelvic pressure is intense as the baby's head engages fully in the pelvis.",
                "You may feel waves of nausea or loose stools in the days before labour begins — this is normal."
            ],
            tips: [
                "Install your infant car seat if not already done — have it checked by a certified inspector.",
                "Know the difference between Braxton Hicks and real labour: true labour contractions get longer, stronger, and closer together over time.",
                "If you plan a home birth, ensure your midwifery team has your updated contact details and that the birth pool (if applicable) is ready."
            ],
            warningSignsToWatch: [
                "Your waters breaking (a gush or continuous trickle) requires contact with your midwifery team, even without contractions.",
                "If your baby has been in a breech or transverse position, confirm the plan with your provider before this week."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 38
        PregnancyWeekContent(
            week: 38,
            fruitComparison: "Pumpkin",
            fruitEmoji: "🎃",
            babySizeCm: 49.8,
            babyWeightGrams: 3083.0,
            babyDevelopment: [
                "The fetus is approximately 49.8 cm and 3.1 kg — fully formed and ready for birth.",
                "The brain and nervous system are continuing to develop connections that will support learning, memory, and coordination after birth.",
                "The fetus's intestines are packed with meconium and their hair may have grown considerably.",
                "Organ systems are functioning at full term capacity — the lungs are mature and ready for independent breathing."
            ],
            motherChanges: [
                "You may experience a 'bloody show' — a pink or red-tinged mucus discharge as the cervix prepares for labour.",
                "Many women experience an energy surge in the 24–48 hours before labour begins.",
                "Emotional readiness varies enormously — anxiety and excitement are both completely normal."
            ],
            tips: [
                "Ensure your birth partner knows your birth plan preferences and can advocate for you clearly.",
                "Get rest whenever possible — you will need your energy reserves for labour.",
                "Confirm with your hospital or birth centre the process for when to come in and who to call."
            ],
            warningSignsToWatch: [
                "Decreased fetal movement should always be reported — do not assume the baby is 'running out of room'.",
                "Sudden, very severe abdominal pain could indicate placental abruption — seek emergency care."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 39
        PregnancyWeekContent(
            week: 39,
            fruitComparison: "Watermelon",
            fruitEmoji: "🍉",
            babySizeCm: 50.7,
            babyWeightGrams: 3288.0,
            babyDevelopment: [
                "At 50.7 cm, the baby's growth is slowing as they reach their final size.",
                "The placenta is beginning to age and its efficiency will decline gradually after 40 weeks.",
                "Brain development — particularly the frontal lobes responsible for planning and emotion — continues to develop rapidly.",
                "The fetus's antibody stores from the placenta are at their maximum, providing important passive immunity after birth."
            ],
            motherChanges: [
                "Cervical dilation and effacement (thinning) progress in preparation for labour — your provider may assess this at your appointment.",
                "You may feel lightning crotch, intense pelvic pressure, or a constant backache as the baby descends.",
                "Many women describe a renewed nesting urgency in the final days before labour."
            ],
            tips: [
                "Stay mobile and active — walking encourages the baby to move into an optimal position for birth.",
                "Practice relaxation techniques and breathing patterns you have prepared for labour.",
                "Accept all offers of support and help — the fourth trimester (postpartum period) will require a village."
            ],
            warningSignsToWatch: [
                "Any cord prolapse (cord visible at the vagina) requires immediate emergency care — call 999/911.",
                "Significantly decreased fetal movement at this stage must be reported immediately — do not dismiss it."
            ],
            source: "NHS, ACOG"
        ),

        // MARK: Week 40
        PregnancyWeekContent(
            week: 40,
            fruitComparison: "Watermelon",
            fruitEmoji: "🍉",
            babySizeCm: 51.2,
            babyWeightGrams: 3462.0,
            babyDevelopment: [
                "Your baby is full term and ready to be born. At approximately 51 cm and 3.4 kg, they are a complete, perfect human being.",
                "The skull remains flexible with fontanelles (soft spots) that allow the head to mould during birth and permit rapid brain growth in the first year.",
                "All organs are fully operational — the lungs, heart, kidneys, liver, and digestive system are ready to work independently.",
                "The baby has accumulated enough fat stores and immunoglobulins to support them in the first days of life."
            ],
            motherChanges: [
                "Your estimated due date is a guideline — only 5% of babies are born exactly on their due date. Going to 41–42 weeks is within the normal range.",
                "Your provider will discuss monitoring and induction options if you reach 41–42 weeks.",
                "Trust your body and your preparation — you are ready for this."
            ],
            tips: [
                "Continue to monitor fetal movements daily — do not assume reduced movement is normal at term.",
                "Try to rest, eat well, and stay hydrated during any early labour (latent phase) at home.",
                "If labour has not begun by 41 weeks, your provider will typically offer a membrane sweep and discuss induction."
            ],
            warningSignsToWatch: [
                "Any decreased fetal movement must be reported immediately — movement does not slow down at term.",
                "If your waters have broken and labour has not begun within 24 hours, contact your midwifery team.",
                "Signs of true labour: contractions 5 minutes apart lasting 60 seconds, a consistent 'show', or your waters breaking."
            ],
            source: "NHS, ACOG"
        )
    ]

    // MARK: - Query Methods

    /// Returns the `PregnancyWeekContent` for the given week number.
    ///
    /// - Parameter week: A week number in the range 1–40.
    /// - Returns: The content for the requested week. Out-of-range values are clamped.
    static func content(for week: Int) -> PregnancyWeekContent {
        let clampedWeek = min(max(week, 1), 40)
        return weeks[clampedWeek - 1]
    }

    /// Returns all weeks belonging to the specified trimester.
    ///
    /// - Parameter trimester: 1, 2, or 3.
    /// - Returns: Array of `PregnancyWeekContent` for the trimester, empty if invalid.
    static func weeks(in trimester: Int) -> [PregnancyWeekContent] {
        weeks.filter { $0.trimester == trimester }
    }
}
