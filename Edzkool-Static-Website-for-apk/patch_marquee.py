import re

with open("components/TopMarquee.tsx", "r") as f:
    content = f.read()

content = re.sub(
    r"const marqueeItems = \[.*?\];",
    """const marqueeItems = [
    `🎓 Enroll Now for Grades 1-10 | Premium 1-on-1 Online Tuition`,
    `🚀 ${EDZKOOL_DATA.company.studentsMentored} Students Empowered Globally`,
    `⚡ Free 1-on-1 Trial Class | Call ${EDZKOOL_DATA.company.phone}`,
    `🌍 Top Programs: IELTS, Coding, English & Academic Tuition`,
    `🎓 Enroll Now for Grades 1-10 | Premium 1-on-1 Online Tuition`,
    `🚀 Interactive Coding for Kids`,
  ];""",
    content,
    flags=re.DOTALL
)

with open("components/TopMarquee.tsx", "w") as f:
    f.write(content)
