# ProjectForge API Documentation

> **Base URL:** `http://localhost:8000/api/v1`
> **Authentication:** Bearer Token (Laravel Sanctum)
> **Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Majors](#majors)
3. [Skills](#skills)
4. [User Skills (Project-DNA)](#user-skills-project-dna)
5. [Projects](#projects)
6. [Recommendations](#recommendations)
7. [Sandbox](#sandbox)
8. [Success Estimation](#success-estimation)
9. [Teams](#teams)
10. [User Profile](#user-profile)
11. [Error Responses](#error-responses)

---

## Authentication

### Register

```
POST /api/v1/register
```

**Body:**
```json
{
  "student_id": "STU-12345",
  "first_name": "Ahmed",
  "last_name": "Mohammed",
  "email": "ahmed@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "gender": "male",
  "date_of_birth": "2002-05-15",
  "major_id": 1,
  "academic_level": 4,
  "role": "student"
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| student_id | string | yes | unique |
| first_name | string | yes | max:255 |
| last_name | string | yes | max:255 |
| email | string | yes | email, unique |
| password | string | yes | min:8, confirmed |
| gender | string | yes | in:male,female |
| date_of_birth | date | yes | valid date |
| major_id | integer | yes | exists:majors,id |
| academic_level | integer | yes | min:1, max:10 |
| role | string | no | in:student,advisor,admin (default: student) |

**Response `201`:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "student_id": "STU-12345",
      "first_name": "Ahmed",
      "last_name": "Mohammed",
      "email": "ahmed@example.com",
      "gender": "male",
      "date_of_birth": "2002-05-15",
      "major_id": 1,
      "academic_level": 4,
      "role": "student"
    },
    "token": "1|abc123def456..."
  }
}
```

---

### Login

```
POST /api/v1/login
```

**Body:**
```json
{
  "email": "ahmed@example.com",
  "password": "password123"
}
```

**Response `200`:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { "...user object..." },
    "token": "2|xyz789..."
  }
}
```

**Response `401`:**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

### Logout

```
POST /api/v1/logout
```

**Headers:** `Authorization: Bearer {token}`

**Response `200`:**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### Get Current User

```
GET /api/v1/me
```

**Headers:** `Authorization: Bearer {token}`

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "student_id": "STU-12345",
    "first_name": "Ahmed",
    "last_name": "Mohammed",
    "email": "ahmed@example.com",
    "gender": "male",
    "date_of_birth": "2002-05-15",
    "major_id": 1,
    "academic_level": 4,
    "role": "student",
    "major": {
      "id": 1,
      "name": "هندسة البرمجيات",
      "code": "SE"
    },
    "skills": [
      {
        "id": 1,
        "name": "Flutter",
        "category": "Frontend",
        "pivot": {
          "proficiency_level": 4
        }
      }
    ]
  }
}
```

---

## Majors

### List All Majors

```
GET /api/v1/majors
```

**Auth:** Public

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "هندسة البرمجيات",
      "code": "SE",
      "created_at": "2026-04-06T15:03:27.000000Z",
      "updated_at": "2026-04-06T15:03:27.000000Z"
    }
  ]
}
```

### Get Single Major

```
GET /api/v1/majors/{id}
```

**Auth:** Public

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "هندسة البرمجيات",
    "code": "SE",
    "users": [ "..." ]
  }
}
```

### Create Major

```
POST /api/v1/majors
```

**Auth:** Admin only (`role:admin`)

**Body:**
```json
{
  "name": "تخصص جديد",
  "code": "NEW"
}
```

### Update Major

```
PUT /api/v1/majors/{id}
```

**Auth:** Admin only

**Body:**
```json
{
  "name": "اسم محدث",
  "code": "UPD"
}
```

### Delete Major

```
DELETE /api/v1/majors/{id}
```

**Auth:** Admin only

---

## Skills

### List All Skills

```
GET /api/v1/skills?category=Frontend
```

**Auth:** Public

**Query Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| category | string | Filter by category (Frontend, Backend, AI/ML, Databases, Programming Languages, Tools, Cloud, Design, Soft Skills) |

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Flutter",
      "category": "Frontend",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

### Get Single Skill

```
GET /api/v1/skills/{id}
```

**Auth:** Public

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Flutter",
    "category": "Frontend",
    "users": [ "..." ],
    "projects": [ "..." ]
  }
}
```

### Create Skill

```
POST /api/v1/skills
```

**Auth:** Admin only

**Body:**
```json
{
  "name": "Rust",
  "category": "Programming Languages"
}
```

### Update Skill

```
PUT /api/v1/skills/{id}
```

**Auth:** Admin only

### Delete Skill

```
DELETE /api/v1/skills/{id}
```

**Auth:** Admin only

---

## User Skills (Project-DNA)

### Get User Skills

```
GET /api/v1/user/skills
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Flutter",
      "category": "Frontend",
      "pivot": {
        "user_id": 1,
        "skill_id": 1,
        "proficiency_level": 4
      }
    }
  ]
}
```

### Update User Skills (Survey)

```
POST /api/v1/user/skills
```

**Auth:** Required

> **Note:** This replaces ALL existing skills. Send the complete list.

**Body:**
```json
{
  "skills": [
    { "skill_id": 1, "proficiency_level": 4 },
    { "skill_id": 2, "proficiency_level": 5 },
    { "skill_id": 22, "proficiency_level": 2 }
  ]
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| skills | array | yes | min:1 |
| skills.*.skill_id | integer | yes | exists:skills,id |
| skills.*.proficiency_level | integer | yes | min:1, max:5 |

**Response `200`:**
```json
{
  "success": true,
  "message": "Skills updated successfully",
  "data": [ "...updated skills list..." ]
}
```

---

## Projects

### List Projects

```
GET /api/v1/projects?type=mobile_app&status=available&difficulty_level=3
```

**Auth:** Public

**Query Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| type | string | Filter by type (mobile_app, web_application, ai_system) |
| status | string | Filter by status (available, in_progress, completed, cancelled) |
| difficulty_level | integer | Filter by difficulty (1-5) |

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "title": "تطبيق إدارة المهام اليومية",
        "description": "تطبيق موبايل لإدارة المهام اليومية",
        "type": "mobile_app",
        "difficulty_level": 3,
        "advisor_id": 1,
        "status": "available",
        "advisor": {
          "id": 1,
          "first_name": "Dr. Ahmed",
          "last_name": "Mohammed"
        },
        "skills": [
          {
            "id": 1,
            "name": "Flutter",
            "category": "Frontend",
            "pivot": {
              "project_id": 1,
              "skill_id": 1,
              "weight": 0.4
            }
          }
        ]
      }
    ],
    "per_page": 10,
    "total": 10,
    "last_page": 1
  }
}
```

### Get Single Project

```
GET /api/v1/projects/{id}
```

**Auth:** Public

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "تطبيق إدارة المهام اليومية",
    "description": "...",
    "type": "mobile_app",
    "difficulty_level": 3,
    "status": "available",
    "advisor": { "...user object..." },
    "skills": [ "...with pivot weight..." ],
    "milestones": [ "...project milestones..." ],
    "risks": [ "...project risks..." ],
    "teams": [
      {
        "id": 1,
        "name": "Team Alpha",
        "members": [
          {
            "id": 1,
            "user_id": 2,
            "role_in_team": "leader"
          }
        ]
      }
    ]
  }
}
```

### Create Project

```
POST /api/v1/projects
```

**Auth:** Required

**Body:**
```json
{
  "title": "مشروع جديد",
  "description": "وصف المشروع",
  "type": "mobile_app",
  "difficulty_level": 3,
  "skills": [
    { "id": 1, "weight": 0.5 },
    { "id": 2, "weight": 0.3 },
    { "id": 22, "weight": 0.2 }
  ]
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| title | string | yes | max:255 |
| description | string | yes | - |
| type | string | yes | - |
| difficulty_level | integer | yes | min:1, max:5 |
| skills | array | yes | min:1 |
| skills.*.id | integer | yes | exists:skills,id |
| skills.*.weight | numeric | yes | min:0, max:1 |

**Response `201`:**
```json
{
  "success": true,
  "message": "Project created successfully",
  "data": { "...project with skills..." }
}
```

### Update Project

```
PUT /api/v1/projects/{id}
```

**Auth:** Required

**Body:** (all fields optional with `sometimes` rule)
```json
{
  "title": "عنوان محدث",
  "description": "وصف محدث",
  "type": "web_application",
  "difficulty_level": 4,
  "status": "in_progress",
  "skills": [
    { "id": 1, "weight": 0.6 },
    { "id": 3, "weight": 0.4 }
  ]
}
```

> **Note:** If `skills` is provided, existing project skills are deleted and replaced.

### Delete Project

```
DELETE /api/v1/projects/{id}
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "message": "Project deleted successfully"
}
```

---

## Recommendations

### Get Recommendations

```
GET /api/v1/recommendations
```

**Auth:** Required

> **Prerequisite:** User must have completed the skills survey (`POST /user/skills`)

**Response `200`:**
```json
{
  "success": true,
  "data": [
    {
      "project": {
        "id": 1,
        "title": "تطبيق إدارة المهام اليومية",
        "description": "...",
        "type": "mobile_app",
        "difficulty_level": 3,
        "status": "available",
        "advisor": { "..." },
        "skills": [ "...with weights..." ]
      },
      "match_score": 0.78,
      "match_percentage": 78.0
    },
    {
      "project": { "..." },
      "match_score": 0.65,
      "match_percentage": 65.0
    }
  ]
}
```

**Response `400` (no skills):**
```json
{
  "success": false,
  "message": "Please complete your skills survey first"
}
```

### Match Score Formula

```
Match Score = Σ (user_proficiency × skill_weight) / Σ (max_proficiency × skill_weight)

Where:
- user_proficiency = user's level for that skill (1-5), 0 if not possessed
- skill_weight = importance of skill in project (0-1)
- max_proficiency = 5

Example:
User: Flutter(4), Dart(5), Firebase(2)
Project requires: Flutter(w:0.5), Dart(w:0.3), Firebase(w:0.2)
Match = (4×0.5 + 5×0.3 + 2×0.2) / (5×0.5 + 5×0.3 + 5×0.2)
      = (2 + 1.5 + 0.4) / (2.5 + 1.5 + 1.0)
      = 3.9 / 5.0 = 78%
```

---

## Sandbox

### Get Sandbox Data

```
GET /api/v1/projects/{id}/sandbox
```

**Auth:** Required

> **Note:** If the project has no milestones or risks, they are auto-generated based on project type.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "project": {
      "id": 1,
      "title": "تطبيق إدارة المهام اليومية",
      "type": "mobile_app",
      "difficulty_level": 3,
      "milestones": [
        {
          "id": 1,
          "title": "تحليل المتطلبات",
          "description": "تحديد متطلبات التطبيق والوظائف الأساسية",
          "estimated_days": 7,
          "order_sequence": 1
        },
        {
          "id": 2,
          "title": "تصميم UI/UX",
          "description": "تصميم واجهات المستخدم وتجربة المستخدم",
          "estimated_days": 10,
          "order_sequence": 2
        }
      ],
      "risks": [
        {
          "id": 1,
          "risk_description": "تغير المتطلبات أثناء التطوير",
          "impact_level": "medium",
          "mitigation_plan": "الالتزام بمنهجية Agile وإدارة التغيير"
        }
      ],
      "skills": [ "..." ]
    },
    "timeline": [
      {
        "milestone_id": 1,
        "title": "تحليل المتطلبات",
        "description": "تحديد متطلبات التطبيق",
        "estimated_days": 7,
        "start_date": "2026-04-15",
        "end_date": "2026-04-22",
        "order": 1
      },
      {
        "milestone_id": 2,
        "title": "تصميم UI/UX",
        "description": "تصميم واجهات المستخدم",
        "estimated_days": 10,
        "start_date": "2026-04-22",
        "end_date": "2026-05-02",
        "order": 2
      }
    ],
    "total_estimated_days": 55
  }
}
```

### Milestone Templates by Project Type

| Type | Milestones | Total Days |
|------|-----------|------------|
| `mobile_app` | تحليل(7) → تصميم(10) → واجهات(14) → Backend(14) → ربط(7) → نشر(3) | 55 |
| `web_application` | تحليل(5) → تصميم(7) → Frontend(12) → Backend(12) → اختبار(5) → نشر(2) | 43 |
| `ai_system` | بيانات(10) → تحليل(7) → نموذج(14) → تدريب(10) → واجهة(10) → نشر(5) | 56 |
| default | تخطيط(7) → تصميم(10) → تطوير(21) → اختبار(7) → نشر(5) | 50 |

---

## Success Estimation

### Estimate for Individual User

```
GET /api/v1/projects/{projectId}/estimate
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "success_probability": 72.5,
    "factors": {
      "skill_coverage": 78.0,
      "team_balance": 100.0,
      "difficulty_factor": 60.0
    },
    "difficulty_level": 3,
    "estimation_id": 1
  }
}
```

### Estimate for Team

```
GET /api/v1/teams/{teamId}/estimate
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "success_probability": 85.3,
    "factors": {
      "skill_coverage": 90.0,
      "team_balance": 82.5,
      "difficulty_factor": 60.0
    },
    "team_size": 4,
    "difficulty_level": 3,
    "estimation_id": 2
  }
}
```

### Success Probability Formula

```
Success% = (Skill_Coverage × 0.5) + (Team_Balance × 0.2) + (Difficulty_Factor × 0.3)

Where:
- Skill_Coverage = weighted coverage of project skills (0-100%)
- Team_Balance = diversity of skills across team members (0-100%)
  - For individual: always 100%
  - For team: calculated via standard deviation of skill distribution
- Difficulty_Factor = (6 - difficulty_level) / 5 × 100
  - Level 1 → 100%
  - Level 3 → 60%
  - Level 5 → 20%
```

---

## Teams

### List Teams

```
GET /api/v1/teams
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "name": "Team Alpha",
        "project_id": 1,
        "is_approved": false,
        "project": { "..." },
        "members": [ "..." ]
      }
    ],
    "per_page": 10,
    "total": 5
  }
}
```

### Create Team

```
POST /api/v1/teams
```

**Auth:** Required

**Body:**
```json
{
  "name": "Team Alpha",
  "project_id": 1
}
```

> The authenticated user is automatically added as `leader`.

**Response `201`:**
```json
{
  "success": true,
  "message": "Team created successfully",
  "data": {
    "id": 1,
    "name": "Team Alpha",
    "project_id": 1,
    "is_approved": false,
    "project": { "..." },
    "members": [
      {
        "id": 1,
        "user_id": 5,
        "role_in_team": "leader"
      }
    ]
  }
}
```

### Get Team

```
GET /api/v1/teams/{id}
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Team Alpha",
    "project_id": 1,
    "is_approved": false,
    "project": { "..." },
    "members": [
      {
        "id": 1,
        "team_id": 1,
        "user_id": 5,
        "role_in_team": "leader",
        "user": {
          "id": 5,
          "first_name": "Ahmed",
          "last_name": "Ali"
        }
      }
    ]
  }
}
```

### Update Team

```
PUT /api/v1/teams/{id}
```

**Auth:** Required

**Body:**
```json
{
  "name": "Team Alpha Updated",
  "is_approved": true
}
```

### Delete Team

```
DELETE /api/v1/teams/{id}
```

**Auth:** Required

### Join Team

```
POST /api/v1/teams/{id}/join
```

**Auth:** Required

> The authenticated user is added as `member`.

**Response `200`:**
```json
{
  "success": true,
  "message": "Successfully joined the team",
  "data": { "...team with updated members..." }
}
```

**Response `400` (already member):**
```json
{
  "success": false,
  "message": "You are already a member of this team"
}
```

---

## User Profile

### List Users

```
GET /api/v1/users
```

**Auth:** Required (any authenticated user)

**Response `200`:** Paginated list with `major` and `skills` relations.

### Get User

```
GET /api/v1/users/{id}
```

**Auth:** Required

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 5,
    "student_id": "STU-00005",
    "first_name": "Ahmed",
    "last_name": "Ali",
    "email": "ahmed@example.com",
    "major": { "..." },
    "skills": [ "...with proficiency_level..." ],
    "teams": [
      {
        "id": 1,
        "name": "Team Alpha",
        "pivot": { "role_in_team": "leader" },
        "project": { "..." }
      }
    ]
  }
}
```

---

## Error Responses

### Standard Error Format

All errors follow this structure:

```json
{
  "success": false,
  "message": "Error description"
}
```

### Validation Error `422`

```json
{
  "message": "The email field is required. (and 1 more error)",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` | Success |
| `201` | Created successfully |
| `400` | Bad request (e.g., no skills, already member) |
| `401` | Unauthorized (not authenticated / invalid token) |
| `403` | Forbidden (insufficient role permissions) |
| `404` | Resource not found |
| `422` | Validation error |
| `500` | Server error |

---

## Quick Reference - All Endpoints

| Method | Endpoint | Auth | Role | Description |
|--------|----------|------|------|-------------|
| POST | `/register` | No | - | Register new user |
| POST | `/login` | No | - | Login |
| POST | `/logout` | Yes | - | Logout |
| GET | `/me` | Yes | - | Get current user |
| GET | `/majors` | No | - | List majors |
| GET | `/majors/{id}` | No | - | Get major |
| POST | `/majors` | Yes | admin | Create major |
| PUT | `/majors/{id}` | Yes | admin | Update major |
| DELETE | `/majors/{id}` | Yes | admin | Delete major |
| GET | `/skills` | No | - | List skills (filter: ?category=) |
| GET | `/skills/{id}` | No | - | Get skill |
| POST | `/skills` | Yes | admin | Create skill |
| PUT | `/skills/{id}` | Yes | admin | Update skill |
| DELETE | `/skills/{id}` | Yes | admin | Delete skill |
| GET | `/user/skills` | Yes | - | Get user's skills |
| POST | `/user/skills` | Yes | - | Update user's skills |
| GET | `/projects` | No | - | List projects (paginated, filter: type, status, difficulty) |
| GET | `/projects/{id}` | No | - | Get project with relations |
| POST | `/projects` | Yes | - | Create project |
| PUT | `/projects/{id}` | Yes | - | Update project |
| DELETE | `/projects/{id}` | Yes | - | Delete project |
| GET | `/recommendations` | Yes | - | Get personalized recommendations |
| GET | `/projects/{id}/sandbox` | Yes | - | Get sandbox (milestones + risks + timeline) |
| GET | `/projects/{id}/estimate` | Yes | - | Estimate success (individual) |
| GET | `/teams` | Yes | - | List teams (paginated) |
| POST | `/teams` | Yes | - | Create team |
| GET | `/teams/{id}` | Yes | - | Get team with members |
| PUT | `/teams/{id}` | Yes | - | Update team |
| DELETE | `/teams/{id}` | Yes | - | Delete team |
| POST | `/teams/{id}/join` | Yes | - | Join team |
| GET | `/teams/{id}/estimate` | Yes | - | Estimate success (team) |
| GET | `/users` | Yes | - | List users (paginated) |
| GET | `/users/{id}` | Yes | - | Get user profile |

**Total: 31 endpoints**

---

## Database Seeding

To populate the database with sample data:

```bash
php artisan migrate:fresh --seed
```

This creates:
- **8 majors** (SE, CS, IS, IT, AI, CYB, CE, DS)
- **40 skills** across 9 categories
- **1 advisor** (advisor@example.com / password)
- **10 projects** with skill requirements and weights
