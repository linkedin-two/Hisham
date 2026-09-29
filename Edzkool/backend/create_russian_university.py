"""
Create dummy Russian university data with courses and feeds.
Run with: python manage.py shell < create_russian_university.py
"""
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'edvoayge.settings')
sys.path.insert(0, 'x:\edvoyage-backup-cursor\backend\edvoayge')
django.setup()

from universities.models import University, Feed
from courses.models import Course, Subject, CourseSubject

def create_russian_university():
    """Create a realistic Russian university with all data."""
    
    # Create University - Saint Petersburg State Medical University
    university, created = University.objects.get_or_create(
        slug='spbgmu-russia',
        defaults={
            'name': 'Saint Petersburg State Medical University',
            'short_name': 'SPbGMU',
            'description': """Saint Petersburg State Medical University (SPbGMU) is one of the oldest and most prestigious medical universities in Russia, founded in 1897. Located in the historic city of Saint Petersburg, the university has been at the forefront of medical education and research for over 125 years.

The university is renowned for its exceptional standards in medical training, combining classical medical education with cutting-edge research and clinical practice. With over 6,000 students from more than 70 countries, SPbGMU offers a truly international learning environment.

The university maintains strong partnerships with leading hospitals and research institutions across Europe and Asia, providing students with extensive practical training opportunities. The faculty includes over 800 professors and doctors of medical sciences, many of whom are internationally recognized experts in their fields.

SPbGMU is recognized by the World Health Organization (WHO), listed in the World Directory of Medical Schools, and is approved by the Medical Council of India (MCI), making it an excellent choice for international students seeking quality medical education at affordable costs.""",
            'mission_statement': 'To educate highly qualified medical professionals who combine deep theoretical knowledge with practical skills, ethical values, and a commitment to lifelong learning, serving the healthcare needs of society through excellence in medical education, research, and patient care.',
            'vision_statement': 'To be a globally recognized center of excellence in medical education and research, fostering innovation in healthcare and producing medical professionals who lead positive change in healthcare systems worldwide.',
            'university_type': 'public',
            'founded_year': 1897,
            'accreditation': 'Ministry of Health of the Russian Federation, WHO Listed, MCI Approved',
            'website': 'https://www.spbgmu.ru',
            'email': 'admissions@spbgmu.ru',
            'phone': '+7 (812) 702-25-70',
            'country': 'Russia',
            'state': 'Saint Petersburg',
            'city': 'Saint Petersburg',
            'address': 'Lev Tolstoy Street, 6-8, Saint Petersburg, Russia, 197022',
            'postal_code': '197022',
            'total_students': 6500,
            'international_students': 2200,
            'faculty_count': 850,
            'is_active': True,
            'is_featured': True,
            'is_verified': True,
        }
    )
    
    if created:
        print(f"[OK] Created University: {university.name}")
    else:
        print(f"ℹ️ University already exists: {university.name}")
    
    return university

def create_courses(university):
    """Create 3 medical courses for the university."""
    
    courses_data = [
        {
            'name': 'Doctor of Medicine (MD) - General Medicine',
            'code': 'SPBGMU-MD-001',
            'description': """The Doctor of Medicine (MD) program at SPbGMU is a comprehensive 6-year medical degree program designed to train world-class physicians. The curriculum integrates theoretical knowledge with extensive clinical practice from the early years of study.

Key Subjects:
• Human Anatomy and Physiology
• Biochemistry and Molecular Biology
• Pathology and Pathophysiology
• Pharmacology and Therapeutics
• Internal Medicine and Surgery
• Pediatrics and Obstetrics
• Neurology and Psychiatry
• Emergency Medicine

Clinical Training:
Students undergo clinical rotations at the university's affiliated hospitals, including the prestigious Saint Petersburg City Hospital and Research Institute of Emergency Medicine. The program emphasizes hands-on patient care under the supervision of experienced clinicians.

Career Outcomes:
Graduates are eligible to practice medicine globally, with many pursuing successful careers in hospitals, research institutions, and healthcare management worldwide. The degree is recognized for licensing examinations in the US (USMLE), UK (PLAB), and India (FMGE).""",
            'short_description': '6-year comprehensive medical degree with extensive clinical training at premier Russian hospitals.',
            'level': 'undergraduate',
            'duration': '4_years',
            'credits': 360,
            'tuition_fee': 450000.00,
            'currency': 'RUB',
            'minimum_gpa': 3.50,
            'language_requirements': 'English proficiency (IELTS 6.0+ or equivalent). Russian language training provided for clinical interactions.',
            'status': 'active',
            'is_featured': True,
            'is_popular': True,
        },
        {
            'name': 'Bachelor of Dental Surgery (BDS)',
            'code': 'SPBGMU-BDS-002',
            'description': """The Bachelor of Dental Surgery program is a 5-year professional degree that prepares students for careers in dentistry and oral health. The program combines rigorous academic training with extensive practical experience in modern dental clinics.

Curriculum Highlights:
• Dental Anatomy and Oral Histology
• Oral Pathology and Microbiology
• Conservative Dentistry and Endodontics
• Oral and Maxillofacial Surgery
• Orthodontics and Dentofacial Orthopedics
• Periodontology and Implant Dentistry
• Prosthodontics and Dental Materials
• Community Dentistry

Practical Training:
Students receive hands-on training at the university's Dental Clinic, equipped with state-of-the-art dental chairs, digital radiography, CAD/CAM systems, and simulation labs. Clinical practice begins in the third year, with students treating patients under expert supervision.

Research Opportunities:
The program offers opportunities to participate in research projects in dental materials science, oral cancer detection, and implantology at the university's Research Institute of Dentistry.

Global Recognition:
The BDS degree from SPbGMU is recognized globally, allowing graduates to pursue licensing examinations and practice dentistry in multiple countries.""",
            'short_description': '5-year professional dental degree with modern clinical facilities and research opportunities.',
            'level': 'undergraduate',
            'duration': '4_years',
            'credits': 300,
            'tuition_fee': 380000.00,
            'currency': 'RUB',
            'minimum_gpa': 3.30,
            'language_requirements': 'English proficiency (IELTS 5.5+ or equivalent). Basic Russian language skills recommended.',
            'status': 'active',
            'is_featured': True,
            'is_popular': False,
        },
        {
            'name': 'Master of Public Health (MPH)',
            'code': 'SPBGMU-MPH-003',
            'description': """The Master of Public Health program is a 2-year postgraduate degree focusing on population health, epidemiology, and healthcare management. This program is ideal for medical graduates and healthcare professionals seeking leadership roles in public health.

Program Focus Areas:
• Epidemiology and Biostatistics
• Health Policy and Management
• Environmental and Occupational Health
• Social and Behavioral Sciences
• Global Health and Health Systems
• Healthcare Quality Improvement
• Health Economics and Financing
• Research Methods in Public Health

Capstone Project:
Students complete a real-world public health project in collaboration with the Saint Petersburg City Health Department or international health organizations. Recent projects have addressed infectious disease surveillance, vaccination campaigns, and healthcare access in rural Russia.

International Collaboration:
The program includes exchange opportunities with partner universities in Germany, Finland, and China. Guest lectures from WHO representatives and CDC experts enrich the learning experience.

Career Paths:
Graduates work as epidemiologists, health policy analysts, hospital administrators, and global health consultants. Many pursue doctoral studies or leadership positions in government health departments and international NGOs.""",
            'short_description': '2-year postgraduate program in public health with focus on epidemiology, health policy, and global health systems.',
            'level': 'postgraduate',
            'duration': '2_years',
            'credits': 120,
            'tuition_fee': 320000.00,
            'currency': 'RUB',
            'minimum_gpa': 3.00,
            'language_requirements': 'English proficiency (IELTS 6.5+ or TOEFL 80+). Prior healthcare experience preferred.',
            'status': 'active',
            'is_featured': False,
            'is_popular': True,
        }
    ]
    
    created_courses = []
    for course_data in courses_data:
        course, created = Course.objects.get_or_create(
            code=course_data['code'],
            defaults={
                'university': university,
                **course_data
            }
        )
        if created:
            print(f"[OK] Created Course: {course.name}")
            created_courses.append(course)
        else:
            print(f"ℹ️ Course already exists: {course.name}")
    
    return created_courses

def create_feeds(university):
    """Create feed entries for the university."""
    
    feeds_data = [
        {
            'user_name': 'Dr. Elena Petrova',
            'title': 'Admissions Open for 2025-2026 Academic Year',
            'description': 'Applications are now being accepted for the upcoming academic year. Early bird scholarships available for students who apply before March 31st. Join our international community of future healthcare leaders! 🎓 #MedicalEducation #StudyInRussia #SPbGMU',
        },
        {
            'user_name': 'Prof. Mikhail Sokolov',
            'title': 'Research Breakthrough in Cardiology',
            'description': 'Our cardiology research team has published groundbreaking findings on novel treatment protocols for heart failure patients. The study, conducted in collaboration with European Heart Institute, shows promising results. Publication available in European Heart Journal. ❤️🔬 #MedicalResearch #Cardiology #Innovation',
        },
        {
            'user_name': 'International Student Office',
            'title': 'Winter Cultural Festival - January 15-20',
            'description': 'Join us for our annual Winter Cultural Festival celebrating the diversity of our international student community! Events include Russian cuisine workshops, international food fair, cultural performances, and ice skating at the historic Neva River. All students welcome! 🌍❄️ #CulturalExchange #StudentLife #SaintPetersburg',
        },
        {
            'user_name': 'Dr. Anastasia Volkov',
            'title': 'New Simulation Center Inaugurated',
            'description': 'We are proud to announce the opening of our state-of-the-art Medical Simulation Center! Equipped with high-fidelity patient simulators, virtual reality surgical trainers, and emergency response scenarios. This facility will enhance practical training for all medical students. 🏥🩺 #MedicalTraining #Simulation #FutureDoctors',
        },
        {
            'user_name': 'Career Development Center',
            'title': 'Job Fair 2025 - Healthcare Employers from 12 Countries',
            'description': 'Mark your calendars! Our annual Healthcare Job Fair is coming up on February 28th. Over 50 hospitals and healthcare organizations from Russia, Germany, UAE, India, and more will be recruiting our graduates. Resume workshops available all week prior to the event. 💼🌍 #CareerOpportunities #HealthcareJobs #GraduateSuccess',
        }
    ]
    
    created_feeds = []
    for feed_data in feeds_data:
        feed, created = Feed.objects.get_or_create(
            university=university,
            title=feed_data['title'],
            defaults=feed_data
        )
        if created:
            print(f"[OK] Created Feed: {feed.title}")
            created_feeds.append(feed)
        else:
            print(f"ℹ️ Feed already exists: {feed.title}")
    
    return created_feeds

def main():
    print("=" * 60)
    print("Creating Russian University Dummy Data")
    print("=" * 60)
    
    # Create university
    university = create_russian_university()
    
    # Create courses
    courses = create_courses(university)
    
    # Create feeds
    feeds = create_feeds(university)
    
    print("=" * 60)
    print("Summary:")
    print(f"  University: {university.name}")
    print(f"  Courses created: {len(courses)}")
    print(f"  Feeds created: {len(feeds)}")
    print("=" * 60)
    print("[OK] Done! Data created successfully.")

if __name__ == '__main__':
    main()
