from django.core.management.base import BaseCommand
from notes.models import Category, Subject, SubSubject, Doctor, Video, MCQ, Question, Option, ClinicalCase, Flashcard
import random


class Command(BaseCommand):

    def handle(self, *args, **kwargs):

        categories = [
            "NEET PG","NEET UG",
            "Class 10","Class 9","Class 8","Class 7",
            "Class 6","Class 5","Class 4","Class 3",
            "Class 2","Class 1"
        ]

        subjects = [
            "Biology","Physics","Chemistry","Mathematics",
            "English","History","Geography","Civics",
            "Computer Science","General Science",
            "Environmental Science","General Knowledge",
            "Logical Reasoning","Mental Ability","Revision"
        ]

        doctors = [
            "Rajesh Kumar","Neha Sharma","Amit Verma","Anjali Mehta",
            "Rohit Singh","Priya Nair","Arjun Patel","Kavita Gupta",
            "Rahul Menon","Sneha Kapoor","Karan Joshi","Divya Reddy",
            "Nishant Gupta","Meera Thomas","Sanjay Kulkarni","Pooja Deshmukh",
            "Varun Khanna","Aisha Khan","Vivek Sharma","Deepak Iyer"
        ]

        youtube_links = [
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",  # Rick Astley - Never Gonna Give You Up (embeddable)
            "https://www.youtube.com/watch?v=9bZkp7q19f0",  # PSY - GANGNAM STYLE (embeddable)
            "https://www.youtube.com/watch?v=kJQP7kiw5Fk",  # Luis Fonsi - Despacito (embeddable)
            "https://www.youtube.com/watch?v=JGwWNGJdvx8",  # Ed Sheeran - Shape of You (embeddable)
            "https://www.youtube.com/watch?v=RgKAFK5djSk",  # Wiz Khalifa - See You Again (embeddable)
            "https://www.youtube.com/watch?v=OPf0YbXqDm0",  # Mark Ronson - Uptown Funk (embeddable)
            "https://www.youtube.com/watch?v=papuvlVeZg8",  # Clean Bandit - Rather Be (embeddable)
            "https://www.youtube.com/watch?v=60ItHLz5WEA",  # Alan Walker - Faded (embeddable)
        ]

        self.stdout.write("Creating Categories")

        category_objs = []
        for c in categories:
            obj, _ = Category.objects.get_or_create(name=c)
            category_objs.append(obj)

        self.stdout.write("Creating Doctors")

        doctor_objs = []
        for d in doctors:
            obj, _ = Doctor.objects.get_or_create(name=d)
            doctor_objs.append(obj)

        self.stdout.write("Creating Subjects")

        subject_objs = []
        for s in subjects:
            obj, _ = Subject.objects.get_or_create(name=s)
            subject_objs.append(obj)

        self.stdout.write("Creating SubSubjects")

        sub_subject_objs = []
        sub_subject_names = ["Chapter 1", "Chapter 2", "Chapter 3", "Unit A", "Unit B"]
        for subject in subject_objs:
            for name in sub_subject_names:
                obj, _ = SubSubject.objects.get_or_create(subject=subject, name=f"{subject.name} - {name}")
                sub_subject_objs.append(obj)

        self.stdout.write("Creating Videos")

        for category in category_objs:
            for i in range(10):
                Video.objects.create(
                    category=category,
                    subject=random.choice(subject_objs),
                    doctor=random.choice(doctor_objs),
                    title=f"{category.name} Lecture {i+1}",
                    video_url=random.choice(youtube_links),
                    is_free=True
                )

        self.stdout.write("Creating MCQ Topics")

        for category in category_objs:
            for i in range(5):
                mcq = MCQ.objects.create(
                    category=category,
                    subject=random.choice(subject_objs),
                    title=f"{category.name} MCQ Topic {i+1}",
                    is_free=True
                )

                for q in range(10):

                    question = Question.objects.create(
                        mcq=mcq,
                        text=f"{category.name} Question {q+1} related to exam preparation?"
                    )

                    correct_index = random.randint(0,3)

                    for o in range(4):

                        Option.objects.create(
                            question=question,
                            text=f"Option {o+1}",
                            is_correct=(o == correct_index)
                        )

        self.stdout.write("Creating Flashcards")

        for category in category_objs:
            for i in range(5):
                subject = random.choice(subject_objs)
                sub_subject = random.choice([ss for ss in sub_subject_objs if ss.subject == subject])
                Flashcard.objects.create(
                    category=category,
                    subject=subject,
                    sub_subject=sub_subject,
                    description=f"{category.name} Flashcard Set {i+1}"
                )

        self.stdout.write("Creating Clinical Cases")

        # Define comprehensive clinical cases for each category
        clinical_cases_data = {
            "NEET PG": [
                ("Acute Myocardial Infarction", "Cardiology", "Cardiovascular System"),
                ("Community Acquired Pneumonia", "Pulmonology", "Respiratory System"),
                ("Diabetic Ketoacidosis", "Endocrinology", "Metabolic Disorders"),
                ("Acute Pancreatitis", "Gastroenterology", "Digestive System"),
                ("Cerebrovascular Accident", "Neurology", "Nervous System"),
                ("Acute Glomerulonephritis", "Nephrology", "Renal System"),
                ("Septic Shock", "Critical Care", "Systemic Infections"),
                ("Acute Liver Failure", "Hepatology", "Hepatobiliary System"),
                ("Meningococcal Meningitis", "Infectious Disease", "CNS Infections"),
                ("Thyroid Storm", "Endocrinology", "Thyroid Disorders"),
                ("Acute Asthma Exacerbation", "Pulmonology", "Respiratory Emergencies"),
                ("Upper GI Bleeding", "Gastroenterology", "GI Emergencies"),
                ("Acute Coronary Syndrome", "Cardiology", "Cardiac Emergencies"),
                ("Malaria with Complications", "Infectious Disease", "Tropical Diseases"),
                ("Hypertensive Emergency", "Cardiology", "Vascular Disorders"),
                ("Acute Kidney Injury", "Nephrology", "Renal Emergencies"),
                ("Status Epilepticus", "Neurology", "Neurological Emergencies"),
                ("Acute Respiratory Distress", "Critical Care", "Respiratory Failure"),
                ("Disseminated Intravascular Coagulation", "Hematology", "Coagulation Disorders"),
                ("Addisonian Crisis", "Endocrinology", "Adrenal Disorders"),
            ],
            "NEET UG": [
                ("Hypertension Management", "Cardiology", "Cardiovascular Health"),
                ("Bronchial Asthma", "Pulmonology", "Respiratory Health"),
                ("Type 2 Diabetes Mellitus", "Endocrinology", "Metabolic Health"),
                ("Peptic Ulcer Disease", "Gastroenterology", "Digestive Health"),
                ("Migraine Headache", "Neurology", "Neurological Conditions"),
                ("Chronic Kidney Disease", "Nephrology", "Renal Health"),
                ("Hypothyroidism", "Endocrinology", "Thyroid Health"),
                ("Rheumatoid Arthritis", "Rheumatology", "Autoimmune Disorders"),
                ("Iron Deficiency Anemia", "Hematology", "Blood Disorders"),
                ("Tuberculosis", "Infectious Disease", "Respiratory Infections"),
                ("Viral Hepatitis", "Hepatology", "Liver Diseases"),
                ("Epilepsy", "Neurology", "Seizure Disorders"),
                ("Congestive Heart Failure", "Cardiology", "Cardiac Conditions"),
                ("Chronic Obstructive Pulmonary Disease", "Pulmonology", "Respiratory Diseases"),
                ("Osteoarthritis", "Orthopedics", "Degenerative Conditions"),
                ("Depression", "Psychiatry", "Mental Health"),
                ("Gastroesophageal Reflux Disease", "Gastroenterology", "GI Conditions"),
                ("Urinary Tract Infection", "Urology", "Genitourinary Health"),
                ("Dengue Fever", "Infectious Disease", "Vector Borne Diseases"),
                ("Typhoid Fever", "Infectious Disease", "Enteric Fever"),
            ],
            "Class 10": [
                ("Nutritional Deficiency", "Pediatrics", "Child Health"),
                ("Common Cold and Flu", "General Medicine", "Infectious Diseases"),
                ("Food Poisoning", "Gastroenterology", "GI Infections"),
                ("Heat Stroke", "Emergency Medicine", "Environmental Diseases"),
                ("Allergic Reaction", "Immunology", "Allergy Management"),
                ("Sports Injury", "Orthopedics", "Trauma Care"),
                ("Stress Management", "Psychology", "Mental Wellness"),
                ("Sleep Disorders", "Neurology", "Sleep Medicine"),
                ("Vision Problems", "Ophthalmology", "Eye Health"),
                ("Dental Caries", "Dentistry", "Oral Health"),
                ("Skin Infections", "Dermatology", "Skin Health"),
                ("Respiratory Infections", "Pediatrics", "Child Respiratory Health"),
                ("Growth and Development", "Pediatrics", "Adolescent Health"),
                ("Immunization Schedule", "Preventive Medicine", "Vaccination"),
                ("Healthy Diet Planning", "Nutrition", "Dietary Health"),
                ("First Aid Basics", "Emergency Medicine", "Basic Life Support"),
                ("Personal Hygiene", "Preventive Medicine", "Hygiene Practices"),
                ("Mental Health Awareness", "Psychology", "Teen Mental Health"),
                ("Substance Abuse Prevention", "Psychiatry", "Addiction Medicine"),
                ("Reproductive Health Education", "Obstetrics", "Adolescent Health"),
            ],
        }

        # Default cases for other categories (Class 1-9)
        default_cases = [
            ("Common Fever Management", "General Medicine", "Basic Healthcare"),
            ("Wound Care and Dressing", "Emergency Medicine", "First Aid"),
            ("Basic Hygiene Practices", "Preventive Medicine", "Health Education"),
            ("Healthy Eating Habits", "Nutrition", "Dietary Health"),
            ("Physical Exercise Benefits", "Sports Medicine", "Fitness"),
            ("Sleep and Rest", "Neurology", "Sleep Health"),
            ("Stress and Coping", "Psychology", "Mental Health"),
            ("Eye Care Basics", "Ophthalmology", "Vision Health"),
            ("Dental Hygiene", "Dentistry", "Oral Care"),
            ("Hand Washing Technique", "Preventive Medicine", "Infection Control"),
            ("Common Cough and Cold", "General Medicine", "Respiratory Health"),
            ("Stomach Pain Management", "Gastroenterology", "Abdominal Pain"),
            ("Headache Causes", "Neurology", "Pain Management"),
            ("Skin Care", "Dermatology", "Skin Health"),
            ("Immunization Importance", "Preventive Medicine", "Vaccination"),
            ("Water and Hydration", "Nutrition", "Hydration"),
            ("Balanced Diet", "Nutrition", "Healthy Eating"),
            ("Personal Safety", "Emergency Medicine", "Safety Education"),
            ("Mental Wellbeing", "Psychology", "Emotional Health"),
            ("Growth Milestones", "Pediatrics", "Child Development"),
        ]

        case_count = 0
        for category in category_objs:
            category_name = category.name
            
            # Get cases for this category
            if category_name in clinical_cases_data:
                cases_for_category = clinical_cases_data[category_name]
            else:
                # For Class 1-9, use default cases with variation
                cases_for_category = default_cases
            
            for case_title, specialty, sub_subject_name in cases_for_category:
                subject = random.choice(subject_objs)
                
                ClinicalCase.objects.create(
                    category=category,
                    subject=subject,
                    doctor=random.choice(doctor_objs),
                    case_title=case_title,
                    gather_equipments=f"Stethoscope, BP apparatus, Thermometer, Pulse oximeter, Examination kit for {specialty}",
                    introduction=f"A patient presents with {case_title.lower()}. This case involves {specialty.lower()} and requires comprehensive clinical assessment. History taking reveals progressive symptoms. Vital signs are documented. Physical examination findings are recorded systematically.",
                    general_inspection=f"Patient appears conscious and oriented. General condition: Moderate. No acute distress visible at rest. Body built: Average. Posture: Normal. Gait: Normal. Skin: No visible rashes or lesions. Nails: Normal. Edema: Not evident. Lymph nodes: Not palpably enlarged.",
                    closer_inspection=f"Detailed examination reveals specific findings related to {case_title.lower()}. Inspection of affected areas shows characteristic signs. Local examination findings correlate with the presenting complaint. No additional abnormalities detected on systematic examination.",
                    palpation=f"Palpation reveals tenderness in relevant anatomical areas. Temperature of skin: Normal. Texture: Normal consistency. Organomegaly: Not detected. Masses: No palpable masses. Pulsations: Normal. Special tests: Appropriate positive/negative findings documented.",
                    final_examination=f"Based on comprehensive clinical evaluation, the diagnosis of {case_title} is established. Differential diagnoses have been ruled out through appropriate investigations. Management plan includes: 1) Immediate interventions, 2) Pharmacological therapy, 3) Monitoring parameters, 4) Patient education, 5) Follow-up schedule.",
                    references=f"Harrison's Principles of Internal Medicine, 21st Edition | Davidson's Principles and Practice of Medicine, 24th Edition | Oxford Handbook of Clinical Medicine, 10th Edition | Current Medical Diagnosis and Treatment | National Guidelines for {specialty} Management"
                )
                case_count += 1

        self.stdout.write(self.style.SUCCESS(f"Created {case_count} clinical cases"))