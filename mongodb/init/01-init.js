// MongoDB initialization script
// This script runs automatically when MongoDB container starts

// Switch to bomcalendar database
db = db.getSiblingDB('bomcalendar');

// Create collections with schema validation
db.createCollection('users', {
    validator: {
        $jsonSchema: {
            bsonType: 'object',
            required: ['email', 'name', 'createdAt'],
            properties: {
                email: {
                    bsonType: 'string',
                    pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
                    description: 'Valid email address required'
                },
                name: {
                    bsonType: 'string',
                    description: 'User full name'
                },
                status: {
                    enum: ['active', 'inactive', 'suspended'],
                    description: 'User account status'
                },
                createdAt: {
                    bsonType: 'date',
                    description: 'Account creation timestamp'
                }
            }
        }
    }
});

db.createCollection('periods');
db.createCollection('events');
db.createCollection('analytics');

// Create indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ status: 1 });
db.users.createIndex({ createdAt: -1 });

db.periods.createIndex({ userId: 1, startDate: -1 });
db.periods.createIndex({ startDate: 1 });

db.events.createIndex({ userId: 1, eventType: 1, eventDate: -1 });
db.events.createIndex({ eventDate: -1 });

// Insert sample data
db.users.insertMany([
    {
        _id: ObjectId(),
        email: 'test@example.com',
        name: 'Test User',
        status: 'active',
        profile: {
            age: 28,
            timezone: 'Asia/Seoul'
        },
        preferences: {
            notifications: true,
            reminderDays: 2
        },
        createdAt: new Date(),
        updatedAt: new Date()
    },
    {
        _id: ObjectId(),
        email: 'jane@example.com',
        name: 'Jane Doe',
        status: 'active',
        profile: {
            age: 32,
            timezone: 'America/New_York'
        },
        preferences: {
            notifications: true,
            reminderDays: 3
        },
        createdAt: new Date(),
        updatedAt: new Date()
    }
]);

// Get user ID for reference
const testUser = db.users.findOne({ email: 'test@example.com' });

// Insert sample periods
db.periods.insertMany([
    {
        userId: testUser._id,
        startDate: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000),
        endDate: new Date(Date.now() - 55 * 24 * 60 * 60 * 1000),
        cycleLength: 28,
        flowType: 'normal',
        symptoms: ['cramps', 'headache'],
        notes: 'Regular cycle',
        createdAt: new Date()
    },
    {
        userId: testUser._id,
        startDate: new Date(Date.now() - 32 * 24 * 60 * 60 * 1000),
        endDate: new Date(Date.now() - 27 * 24 * 60 * 60 * 1000),
        cycleLength: 28,
        flowType: 'normal',
        symptoms: ['fatigue'],
        notes: 'Regular cycle',
        createdAt: new Date()
    },
    {
        userId: testUser._id,
        startDate: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
        endDate: new Date(),
        cycleLength: 28,
        flowType: 'normal',
        symptoms: ['mild cramps'],
        notes: 'Current cycle',
        createdAt: new Date()
    }
]);

// Insert sample events
db.events.insertMany([
    {
        userId: testUser._id,
        eventType: 'symptom',
        eventDate: new Date(),
        description: 'Headache',
        metadata: {
            severity: 'mild',
            duration: '2 hours'
        },
        createdAt: new Date()
    },
    {
        userId: testUser._id,
        eventType: 'medication',
        eventDate: new Date(Date.now() - 24 * 60 * 60 * 1000),
        description: 'Pain reliever',
        metadata: {
            name: 'Ibuprofen',
            dosage: '200mg'
        },
        createdAt: new Date()
    },
    {
        userId: testUser._id,
        eventType: 'mood',
        eventDate: new Date(),
        description: 'Feeling good',
        metadata: {
            mood: 'happy',
            energy: 8
        },
        createdAt: new Date()
    }
]);

// Create analytics collection with aggregated data
db.analytics.insertOne({
    userId: testUser._id,
    periodSummary: {
        averageCycleLength: 28,
        totalCycles: 3,
        lastPeriodDate: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
        predictedNextDate: new Date(Date.now() + 24 * 24 * 60 * 60 * 1000)
    },
    commonSymptoms: ['cramps', 'headache', 'fatigue'],
    lastUpdated: new Date()
});

// Create a view for user statistics
db.createView(
    'userStatistics',
    'periods',
    [
        {
            $group: {
                _id: '$userId',
                totalPeriods: { $sum: 1 },
                averageCycleLength: { $avg: '$cycleLength' },
                lastPeriod: { $max: '$startDate' }
            }
        }
    ]
);

print('✅ MongoDB initialization complete!');
print('📊 Collections created: users, periods, events, analytics');
print('📈 View created: userStatistics');
print('🔍 Indexes created for optimal query performance');