with open("data/edzkool-data.ts", "r") as f:
    content = f.read()

content = content.replace("export interface Faq {", "export interface ServiceItem {\n  title: string;\n  description: string;\n  icon: string;\n}\n\nexport interface Faq {")

with open("data/edzkool-data.ts", "w") as f:
    f.write(content)
