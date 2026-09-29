from django.core.management.base import BaseCommand
from chatapp.models import UserSimple, Conversation, Message
from django.utils import timezone

class Command(BaseCommand):
    help = 'Populate database with dummy users and conversations'

    def handle(self, *args, **kwargs):
        self.stdout.write('Creating dummy users...')
        
        # Create dummy users
        users_data = [
            {
                'email': 'alice@example.com',
                'name': 'Alice Johnson',
                'role': 'Student',
                'avatar': 'https://i.pravatar.cc/150?img=1',
            },
            {
                'email': 'bob@example.com',
                'name': 'Bob Smith',
                'role': 'Teacher',
                'avatar': 'https://i.pravatar.cc/150?img=2',
            },
            {
                'email': 'carol@example.com',
                'name': 'Carol Williams',
                'role': 'Student',
                'avatar': 'https://i.pravatar.cc/150?img=3',
            },
            {
                'email': 'dave@example.com',
                'name': 'Dave Brown',
                'role': 'Admin',
                'avatar': 'https://i.pravatar.cc/150?img=4',
            },
            {
                'email': 'emma@example.com',
                'name': 'Emma Davis',
                'role': 'Student',
                'avatar': 'https://i.pravatar.cc/150?img=5',
            },
            {
                'email': 'frank@example.com',
                'name': 'Frank Miller',
                'role': 'Teacher',
                'avatar': 'https://i.pravatar.cc/150?img=6',
            },
            {
                'email': 'grace@example.com',
                'name': 'Grace Wilson',
                'role': 'Student',
                'avatar': 'https://i.pravatar.cc/150?img=7',
            },
            {
                'email': 'henry@example.com',
                'name': 'Henry Moore',
                'role': 'Student',
                'avatar': 'https://i.pravatar.cc/150?img=8',
            },
        ]
        
        users = []
        for user_data in users_data:
            user, created = UserSimple.objects.get_or_create(
                email=user_data['email'],
                defaults=user_data
            )
            users.append(user)
            if created:
                self.stdout.write(f'  Created: {user.name} ({user.email})')
            else:
                self.stdout.write(f'  Exists: {user.name} ({user.email})')
        
        self.stdout.write('\nCreating conversations and messages...')
        
        # Create conversations with sample messages
        conversations_data = [
            # (user_a_index, user_b_index, messages)
            (0, 1, [  # Alice and Bob
                ('alice@example.com', 'Hi Bob! How are you doing?', True, True),
                ('bob@example.com', 'Hey Alice! I\'m doing great, thanks for asking!', True, True),
                ('alice@example.com', 'Are you free for a quick study session tomorrow?', True, False),
                ('bob@example.com', 'Sure! What time works for you?', False, False),
            ]),
            (0, 2, [  # Alice and Carol
                ('alice@example.com', 'Carol, did you finish the assignment?', True, True),
                ('carol@example.com', 'Yes! Just submitted it an hour ago.', True, True),
                ('alice@example.com', 'Awesome! How did it go?', True, False),
            ]),
            (1, 3, [  # Bob and Dave
                ('dave@example.com', 'Bob, can you review the new curriculum?', True, True),
                ('bob@example.com', 'Of course! I\'ll look at it this evening.', True, True),
                ('dave@example.com', 'Thanks, appreciate it!', True, True),
                ('bob@example.com', 'No problem at all!', True, False),
            ]),
            (2, 4, [  # Carol and Emma
                ('emma@example.com', 'Hey Carol! Want to join our study group?', True, True),
                ('carol@example.com', 'That sounds great! When do you meet?', True, True),
                ('emma@example.com', 'Every Tuesday and Thursday at 4pm.', True, False),
            ]),
            (4, 5, [  # Emma and Frank
                ('emma@example.com', 'Mr. Miller, I have a question about today\'s lesson.', True, True),
                ('frank@example.com', 'Of course Emma, what would you like to know?', True, True),
                ('emma@example.com', 'I\'m confused about the third problem.', True, False),
            ]),
            (5, 6, [  # Frank and Grace
                ('frank@example.com', 'Grace, your project presentation was excellent!', True, True),
                ('grace@example.com', 'Thank you so much Mr. Miller!', True, True),
                ('frank@example.com', 'Keep up the great work!', True, True),
            ]),
            (6, 7, [  # Grace and Henry
                ('grace@example.com', 'Henry, did you see the exam schedule?', True, True),
                ('henry@example.com', 'Yes, it\'s going to be tough!', True, True),
                ('grace@example.com', 'We should start studying together.', True, False),
            ]),
            (0, 7, [  # Alice and Henry
                ('alice@example.com', 'Hi Henry! Long time no see!', True, True),
                ('henry@example.com', 'Alice! It\'s been ages! How have you been?', True, True),
                ('alice@example.com', 'Doing well! Let\'s catch up soon.', True, True),
                ('henry@example.com', 'Definitely! Coffee next week?', True, False),
            ]),
        ]
        
        for user_a_idx, user_b_idx, messages_data in conversations_data:
            user_a = users[user_a_idx]
            user_b = users[user_b_idx]
            
            # Create conversation
            conv, created = Conversation.objects.get_or_create(
                user_a=user_a,
                user_b=user_b,
            )
            
            if created:
                self.stdout.write(f'  Created conversation: {user_a.name} <-> {user_b.name}')
            else:
                self.stdout.write(f'  Exists conversation: {user_a.name} <-> {user_b.name}')
            
            # Add messages
            for sender_email, text, delivered, seen in messages_data:
                sender = UserSimple.objects.get(email=sender_email)
                
                # Check if message already exists (avoid duplicates)
                existing = Message.objects.filter(
                    conversation=conv,
                    sender=sender,
                    text=text
                ).first()
                
                if not existing:
                    Message.objects.create(
                        conversation=conv,
                        sender=sender,
                        text=text,
                        delivered=delivered,
                        seen=seen,
                    )
                    status = 'SEEN' if seen else ('SENT' if delivered else 'PENDING')
                    self.stdout.write(f'    [{status}] {sender.name}: {text[:40]}...')
        
        self.stdout.write(self.style.SUCCESS('\n[SUCCESS] Dummy data created successfully!'))
        self.stdout.write(f'   Users: {UserSimple.objects.count()}')
        self.stdout.write(f'   Conversations: {Conversation.objects.count()}')
        self.stdout.write(f'   Messages: {Message.objects.count()}')
