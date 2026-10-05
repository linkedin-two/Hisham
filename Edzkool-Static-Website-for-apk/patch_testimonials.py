with open("components/Testimonials.tsx", "r") as f:
    content = f.read()

content = content.replace("t.rating", "5")
content = content.replace("t.studentName", "t.name")
content = content.replace("t.university", "t.exam")
content = content.replace("t.country", "t.score")
content = content.replace("t.year", "''")

with open("components/Testimonials.tsx", "w") as f:
    f.write(content)
