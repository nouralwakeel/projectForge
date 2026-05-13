# ProjectForge API Documentation

> **Base URL:** `http://localhost:8000/api/v1`
> **Authentication:** Bearer Token (Laravel Sanctum)
> **Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#authentication)
2. [User Profile](#user-profile)
3. [User Skills (Project-DNA)](#user-skills-project-dna)
4. [Majors](#majors)
5. [Skills](#skills)
6. [Projects](#projects)
7. [Recommendations](#recommendations)
8. [Sandbox](#sandbox)
9. [Success Estimation](#success-estimation)
10. [Teams](#teams)
11. [Error Responses](#error-responses)
12. [Quick Reference](#quick-reference---all-endpoints)
13. [Database Schema](#database-schema)

---

## Authentication

### Register

```
POST /api/v1/register
```

**Auth:** Public

Creates a new user. If `role` is `student` (default), a `Student` profile is also created.

**Body:**
```json
{
  "name": "Dr. Ahmed",
  "email": "ahmed@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "role": "student",
  "stud_num": "STU-12345",
  "first_name": "Ahmed",
  "last_name": "Mohammed",
  "gender": "male",
  "date_of_birth": "2002-05-15",
  "major_id": 1
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | yes (unless student) | max:255 |
| email | string | yes | email, unique:users,email |
| password | string | yes | min:8, confirmed |
| password_confirmation | string | yes | must match password |
| role | string | no | in:student,advisor,admin (default: student) |
| stud_num | string | yes if student | unique:students,stud_num |
| first_name | string | yes if student | max:255 |
| last_name | string | yes if student | max:255 |
| gender | string | yes if student | in:male,female |
| date_of_birth | date | yes if student | valid date |
| major_id | integer | yes if student | exists:majors,id |

**Response `201`:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "Ahmed Mohammed",
      "email": "ahmed@example.com",
      "role": "student",
      "email_verified_at": null,
      "created_at": "2026-04-06T15:03:27.000000Z",
      "updated_at": "2026-04-06T15:03:27.000000Z",
      "student": {
        "id": 1,
        "user_id": 1,
        "stud_num": "STU-12345",
        "first_name": "Ahmed",
        "last_name": "Mohammed",
        "gender": "male",
        "date_of_birth": "2002-05-15",
        "major_id": 1,
        "created_at": "...",
        "updated_at": "..."
      }
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

**Auth:** Public

**Body:**
```json
{
  "email": "ahmed@example.com",
  "password": "password123"
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| email | string | yes | email |
| password | string | yes | string |

**Response `200`:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Ahmed Mohammed",
      "email": "ahmed@example.com",
      "role": "student",
      "student": { "..." }
    },
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

**Auth:** Required (Bearer Token)

Invalidates the current access token.

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

**Auth:** Required (Bearer Token)

Returns the authenticated user with their student profile, major, and skills.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Ahmed Mohammed",
    "email": "ahmed@example.com",
    "role": "student",
    "student": {
      "id": 1,
      "user_id": 1,
      "stud_num": "STU-12345",
      "first_name": "Ahmed",
      "last_name": "Mohammed",
      "gender": "male",
      "date_of_birth": "2002-05-15",
      "major_id": 1,
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
            "student_id": 1,
            "skill_id": 1,
            "proficiency_level": 4,
            "interest_level": 5
          }
        }
      ]
    }
  }
}
```

---

## User Profile

### Update User Skills (Survey)

```
POST /api/v1/user/skills
```

**Auth:** Required (Bearer Token)

> **Important:** This **replaces ALL** existing skills. Send the complete list every time.

**Body:**
```json
{
  "skills": [
    { "skill_id": 1, "proficiency_level": 4, "interest_level": 5 },
    { "skill_id": 2, "proficiency_level": 5, "interest_level": 4 },
    { "skill_id": 22, "proficiency_level": 2, "interest_level": 3 }
  ]
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| skills | array | yes | min:1 |
| skills.*.skill_id | integer | yes | exists:skills,id |
| skills.*.proficiency_level | integer | yes | min:1, max:5 |
| skills.*.interest_level | integer | yes | min:1, max:5 |

**Response `200`:**
```json
{
  "success": true,
  "message": "Skills updated successfully",
  "data": [
    {
      "id": 1,
      "name": "Flutter",
      "category": "Frontend",
      "pivot": {
        "student_id": 1,
        "skill_id": 1,
        "proficiency_level": 4,
        "interest_level": 5
      }
    }
  ]
}
```

**Response `404` (non-student):**
```json
{
  "success": false,
  "message": "Student profile not found"
}
```

---

### Get User Skills

```
GET /api/v1/user/skills
```

**Auth:** Required (Bearer Token)

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
        "student_id": 1,
        "skill_id": 1,
        "proficiency_level": 4,
        "interest_level": 5
      }
    }
  ]
}
```

**Response `404` (non-student):**
```json
{
  "success": false,
  "message": "Student profile not found"
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
    },
    {
      "id": 2,
      "name": "علوم الحاسب",
      "code": "CS",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

---

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
    "students": [
      {
        "id": 1,
        "user_id": 1,
        "stud_num": "STU-12345",
        "first_name": "Ahmed",
        "last_name": "Mohammed",
        "gender": "male",
        "date_of_birth": "2002-05-15",
        "major_id": 1
      }
    ]
  }
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Major not found"
}
```

---

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

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | yes | max:255 |
| code | string | yes | unique:majors,code |

**Response `201`:**
```json
{
  "success": true,
  "message": "Major created successfully",
  "data": {
    "id": 9,
    "name": "تخصص جديد",
    "code": "NEW"
  }
}
```

---

### Update Major

```
PUT /api/v1/majors/{id}
```

**Auth:** Admin only (`role:admin`)

**Body:** (all fields optional)
```json
{
  "name": "اسم محدث",
  "code": "UPD"
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | no | max:255 |
| code | string | no | unique:majors,code,{id} |

**Response `200`:**
```json
{
  "success": true,
  "message": "Major updated successfully",
  "data": {
    "id": 1,
    "name": "اسم محدث",
    "code": "UPD"
  }
}
```

---

### Delete Major

```
DELETE /api/v1/majors/{id}
```

**Auth:** Admin only (`role:admin`)

**Response `200`:**
```json
{
  "success": true,
  "message": "Major deleted successfully"
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Major not found"
}
```

---

## Skills

### List All Skills

```
GET /api/v1/skills?category=Frontend
```

**Auth:** Public

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| category | string | no | Filter by category |

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
    },
    {
      "id": 2,
      "name": "React",
      "category": "Frontend",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

---

### Get Single Skill

```
GET /api/v1/skills/{id}
```

**Auth:** Public

Returns the skill with its related students and projects.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Flutter",
    "category": "Frontend",
    "students": [
      {
        "id": 1,
        "stud_num": "STU-12345",
        "first_name": "Ahmed",
        "last_name": "Mohammed",
        "pivot": {
          "proficiency_level": 4,
          "interest_level": 5
        }
      }
    ],
    "projects": [
      {
        "id": 1,
        "title": "تطبيق إدارة المهام",
        "pivot": {
          "weight": "0.40"
        }
      }
    ]
  }
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Skill not found"
}
```

---

### Create Skill

```
POST /api/v1/skills
```

**Auth:** Admin only (`role:admin`)

**Body:**
```json
{
  "name": "Rust",
  "category": "Programming Languages"
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | yes | max:255 |
| category | string | yes | max:255 |

**Response `201`:**
```json
{
  "success": true,
  "message": "Skill created successfully",
  "data": {
    "id": 41,
    "name": "Rust",
    "category": "Programming Languages"
  }
}
```

---

### Update Skill

```
PUT /api/v1/skills/{id}
```

**Auth:** Admin only (`role:admin`)

**Body:** (all fields optional)
```json
{
  "name": "Rust Updated",
  "category": "Systems Programming"
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | no | max:255 |
| category | string | no | max:255 |

**Response `200`:**
```json
{
  "success": true,
  "message": "Skill updated successfully",
  "data": {
    "id": 41,
    "name": "Rust Updated",
    "category": "Systems Programming"
  }
}
```

---

### Delete Skill

```
DELETE /api/v1/skills/{id}
```

**Auth:** Admin only (`role:admin`)

**Response `200`:**
```json
{
  "success": true,
  "message": "Skill deleted successfully"
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Skill not found"
}
```

---

## Projects

### List Projects

```
GET /api/v1/projects?type_id=1&status=available&difficulty_level=3
```

**Auth:** Public (paginated, 10 per page)

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| type_id | integer | no | Filter by project type (FK to project_types) |
| status | string | no | Filter by status: available, in_progress, completed, cancelled |
| difficulty_level | integer | no | Filter by difficulty (1-5) |

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
        "type_id": 1,
        "difficulty_level": 3,
        "supervisor_id": 1,
        "status": "available",
        "created_at": "...",
        "updated_at": "...",
        "supervisor": {
          "id": 1,
          "name": "Dr. Ahmed",
          "email": "advisor@example.com",
          "role": "advisor"
        },
        "type": {
          "id": 1,
          "name": "mobile_app"
        },
        "skills": [
          {
            "id": 1,
            "name": "Flutter",
            "category": "Frontend",
            "pivot": {
              "project_id": 1,
              "skill_id": 1,
              "weight": "0.40"
            }
          }
        ]
      }
    ],
    "first_page_url": "http://localhost:8000/api/v1/projects?page=1",
    "from": 1,
    "last_page": 1,
    "last_page_url": "...",
    "next_page_url": null,
    "path": "http://localhost:8000/api/v1/projects",
    "per_page": 10,
    "prev_page_url": null,
    "to": 10,
    "total": 10
  }
}
```

---

### Get Single Project

```
GET /api/v1/projects/{id}
```

**Auth:** Public

Returns the project with supervisor, type, skills, milestones, risks, and teams with members.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "تطبيق إدارة المهام اليومية",
    "description": "تطبيق موبايل لإدارة المهام اليومية",
    "type_id": 1,
    "difficulty_level": 3,
    "supervisor_id": 1,
    "status": "available",
    "supervisor": {
      "id": 1,
      "name": "Dr. Ahmed",
      "email": "advisor@example.com"
    },
    "type": {
      "id": 1,
      "name": "mobile_app"
    },
    "skills": [
      {
        "id": 1,
        "name": "Flutter",
        "category": "Frontend",
        "pivot": {
          "project_id": 1,
          "skill_id": 1,
          "weight": "0.40"
        }
      }
    ],
    "milestones": [
      {
        "id": 1,
        "project_id": 1,
        "title": "تحليل المتطلبات",
        "description": "تحديد متطلبات التطبيق والوظائف الأساسية",
        "estimated_days": 7,
        "order_sequence": 1
      }
    ],
    "risks": [
      {
        "id": 1,
        "project_id": 1,
        "risk_description": "تغير المتطلبات أثناء التطوير",
        "impact_level": "Medium",
        "mitigation_plan": "الالتزام بمنهجية Agile وإدارة التغيير"
      }
    ],
    "teams": [
      {
        "id": 1,
        "name": "Team Alpha",
        "project_id": 1,
        "is_approved": false,
        "members": [
          {
            "id": 1,
            "stud_num": "STU-12345",
            "first_name": "Ahmed",
            "last_name": "Mohammed",
            "pivot": {
              "role_in_team": "leader"
            }
          }
        ]
      }
    ]
  }
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Project not found"
}
```

---

### Create Project

```
POST /api/v1/projects
```

**Auth:** Required (Bearer Token)

**Body:**
```json
{
  "title": "مشروع جديد",
  "description": "وصف المشروع",
  "type_id": 1,
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
| description | string | yes | string |
| type_id | integer | yes | exists:project_types,id |
| difficulty_level | integer | yes | min:1, max:5 |
| skills | array | yes | min:1 |
| skills.*.id | integer | yes | exists:skills,id |
| skills.*.weight | numeric | yes | min:0, max:1 |
| supervisor_id | integer | no | defaults to authenticated user id |

> The `status` is automatically set to `available` on creation.

**Response `201`:**
```json
{
  "success": true,
  "message": "Project created successfully",
  "data": {
    "id": 11,
    "title": "مشروع جديد",
    "description": "وصف المشروع",
    "type_id": 1,
    "difficulty_level": 3,
    "supervisor_id": 5,
    "status": "available",
    "supervisor": { "..." },
    "type": { "..." },
    "skills": [ "..." ]
  }
}
```

---

### Update Project

```
PUT /api/v1/projects/{id}
```

**Auth:** Required (Bearer Token)

**Body:** (all fields optional)
```json
{
  "title": "عنوان محدث",
  "description": "وصف محدث",
  "type_id": 2,
  "difficulty_level": 4,
  "status": "in_progress",
  "skills": [
    { "id": 1, "weight": 0.6 },
    { "id": 3, "weight": 0.4 }
  ]
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| title | string | no | max:255 |
| description | string | no | string |
| type_id | integer | no | exists:project_types,id |
| difficulty_level | integer | no | min:1, max:5 |
| status | string | no | in:available,in_progress,completed,cancelled |
| skills | array | no | If provided, replaces all existing project skills |

> **Note:** If `skills` is provided, all existing project skills are deleted and replaced with the new list.

**Response `200`:**
```json
{
  "success": true,
  "message": "Project updated successfully",
  "data": { "...project with relations..." }
}
```

---

### Delete Project

```
DELETE /api/v1/projects/{id}
```

**Auth:** Required (Bearer Token)

**Response `200`:**
```json
{
  "success": true,
  "message": "Project deleted successfully"
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Project not found"
}
```

---

## Recommendations

### Get Personalized Recommendations

```
GET /api/v1/recommendations
```

**Auth:** Required (Bearer Token)

Returns up to 10 projects ranked by match score based on the authenticated student's skills.

> **Prerequisites:**
> - Authenticated user must have a student profile
> - Student must have completed the skills survey (`POST /user/skills`)

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
        "type_id": 1,
        "difficulty_level": 3,
        "status": "available",
        "supervisor": { "..." },
        "type": { "..." },
        "skills": [
          {
            "id": 1,
            "name": "Flutter",
            "category": "Frontend",
            "pivot": {
              "project_id": 1,
              "skill_id": 1,
              "weight": "0.40"
            }
          }
        ]
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

**Response `404` (no student profile):**
```json
{
  "success": false,
  "message": "Student profile not found"
}
```

### Match Score Formula

```
Match Score = Σ (student_proficiency × skill_weight) / Σ (max_proficiency × skill_weight)

Where:
- student_proficiency = student's proficiency level for that skill (1-5), 0 if not possessed
- skill_weight = importance of skill in the project (0-1)
- max_proficiency = 5

Only projects with match_score > 0 are returned, sorted descending.
Maximum 10 recommendations.
```

---

## Sandbox

### Get Sandbox Data

```
GET /api/v1/projects/{id}/sandbox
```

**Auth:** Required (Bearer Token)

Returns project sandbox data including milestones, risks, and a computed timeline.

> **Note:** If the project has no milestones or risks, they are **auto-generated** based on the project type (`project_types.name`) and difficulty level.

**Response `200`:**
```json
{
  "success": true,
  "data": {
    "project": {
      "id": 1,
      "title": "تطبيق إدارة المهام اليومية",
      "type_id": 1,
      "difficulty_level": 3,
      "status": "available",
      "type": {
        "id": 1,
        "name": "mobile_app"
      },
      "milestones": [
        {
          "id": 1,
          "project_id": 1,
          "title": "تحليل المتطلبات",
          "description": "تحديد متطلبات التطبيق والوظائف الأساسية",
          "estimated_days": 7,
          "order_sequence": 1
        },
        {
          "id": 2,
          "project_id": 1,
          "title": "تصميم UI/UX",
          "description": "تصميم واجهات المستخدم وتجربة المستخدم",
          "estimated_days": 10,
          "order_sequence": 2
        }
      ],
      "risks": [
        {
          "id": 1,
          "project_id": 1,
          "risk_description": "تغير المتطلبات أثناء التطوير",
          "impact_level": "Medium",
          "mitigation_plan": "الالتزام بمنهجية Agile وإدارة التغيير"
        }
      ],
      "skills": [ "..." ]
    },
    "timeline": [
      {
        "milestone_id": 1,
        "title": "تحليل المتطلبات",
        "description": "تحديد متطلبات التطبيق والوظائف الأساسية",
        "estimated_days": 7,
        "start_date": "2026-05-02",
        "end_date": "2026-05-09",
        "order": 1
      },
      {
        "milestone_id": 2,
        "title": "تصميم UI/UX",
        "description": "تصميم واجهات المستخدم وتجربة المستخدم",
        "estimated_days": 10,
        "start_date": "2026-05-09",
        "end_date": "2026-05-19",
        "order": 2
      },
      {
        "milestone_id": 3,
        "title": "بناء الواجهات الأمامية",
        "description": "تطوير شاشات وواجهات التطبيق",
        "estimated_days": 14,
        "start_date": "2026-05-19",
        "end_date": "2026-06-02",
        "order": 3
      }
    ],
    "total_estimated_days": 55
  }
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Project not found"
}
```

### Milestone Templates by Project Type

Milestones are generated based on `project_types.name`:

| Type Name | Milestones (days) | Total Days |
|-----------|-------------------|------------|
| `mobile_app` | تحليل المتطلبات(7) → تصميم UI/UX(10) → بناء الواجهات(14) → بناء Backend(14) → الربط والاختبار(7) → النشر(3) | **55** |
| `web_application` | تحليل المتطلبات(5) → تصميم الموقع(7) → برمجة Frontend(12) → برمجة Backend(12) → اختبار وتحسين(5) → النشر(2) | **43** |
| `ai_system` | جمع البيانات(10) → تحليل واستكشاف(7) → بناء النموذج(14) → تدريب وتقييم(10) → بناء واجهة(10) → النشر(5) | **56** |
| default (any other) | التخطيط والتحليل(7) → التصميم(10) → التطوير(21) → الاختبار(7) → النشر والتوثيق(5) | **50** |

### Risk Templates

Risks are generated per project type. Additional risks are added for high difficulty:

| Difficulty | Additional Risk | Impact |
|------------|----------------|--------|
| >= 4 | "تعقيد المشروع قد يؤدي لتأخير كبير" | High |
| >= 5 | "احتمالية عدم إكمال المشروع بالكامل" | High |

---

## Success Estimation

### Estimate for Individual Student

```
GET /api/v1/projects/{projectId}/estimate
```

**Auth:** Required (Bearer Token)

Calculates the success probability for the authenticated student on a specific project. The result is stored in `success_estimations`.

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

**Response `404`:**
```json
{
  "success": false,
  "message": "Project not found"
}
```
or
```json
{
  "success": false,
  "message": "Student profile not found"
}
```

---

### Estimate for Team

```
GET /api/v1/teams/{teamId}/estimate
```

**Auth:** Required (Bearer Token)

Calculates the success probability for an entire team on their assigned project. Uses combined team skills and team balance metrics.

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

**Response `400` (no project):**
```json
{
  "success": false,
  "message": "Team has no project assigned"
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Team not found"
}
```

### Success Probability Formula

```
Success% = (Skill_Coverage × 0.5) + (Team_Balance × 0.2) + (Difficulty_Factor × 0.3)

Where:
- Skill_Coverage (50% weight): weighted coverage of project-required skills
  - For individual: student's proficiency / max_proficiency × skill_weight
  - For team: max proficiency among all members for each skill
- Team_Balance (20% weight): diversity of skills across team members
  - For individual: always 100% (1.0)
  - For team: calculated via standard deviation of skill distribution (min 50%)
- Difficulty_Factor (30% weight): inverse difficulty
  - (6 - difficulty_level) / 5
  - Level 1 → 100%
  - Level 3 → 60%
  - Level 5 → 20%

Result is capped at 100%.
```

---

## Teams

### List Teams

```
GET /api/v1/teams
```

**Auth:** Required (Bearer Token)

Returns paginated teams (10 per page) with their project and members.

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
        "project": {
          "id": 1,
          "title": "تطبيق إدارة المهام اليومية",
          "status": "available"
        },
        "members": [
          {
            "id": 1,
            "stud_num": "STU-12345",
            "first_name": "Ahmed",
            "pivot": {
              "role_in_team": "leader"
            }
          }
        ]
      }
    ],
    "per_page": 10,
    "total": 5,
    "last_page": 1
  }
}
```

---

### Create Team

```
POST /api/v1/teams
```

**Auth:** Required (Bearer Token)

Creates a team for a project. The authenticated student is automatically added as `leader`. The team's `is_approved` is set to `false` by default.

**Body:**
```json
{
  "name": "Team Alpha",
  "project_id": 1
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | yes | max:255 |
| project_id | integer | yes | exists:projects,id |

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
        "stud_num": "STU-12345",
        "first_name": "Ahmed",
        "last_name": "Mohammed",
        "pivot": {
          "role_in_team": "leader"
        }
      }
    ]
  }
}
```

**Response `404` (non-student):**
```json
{
  "success": false,
  "message": "Student profile not found"
}
```

---

### Get Team

```
GET /api/v1/teams/{id}
```

**Auth:** Required (Bearer Token)

Returns team with project and members (including member student details).

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
        "stud_num": "STU-12345",
        "first_name": "Ahmed",
        "last_name": "Mohammed",
        "pivot": {
          "role_in_team": "leader"
        },
        "student": {
          "id": 1,
          "user_id": 5,
          "stud_num": "STU-12345",
          "first_name": "Ahmed",
          "last_name": "Mohammed"
        }
      }
    ]
  }
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Team not found"
}
```

---

### Update Team

```
PUT /api/v1/teams/{id}
```

**Auth:** Required (Bearer Token)

**Body:** (all fields optional)
```json
{
  "name": "Team Alpha Updated",
  "is_approved": true
}
```

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| name | string | no | max:255 |
| is_approved | boolean | no | boolean |

**Response `200`:**
```json
{
  "success": true,
  "message": "Team updated successfully",
  "data": {
    "id": 1,
    "name": "Team Alpha Updated",
    "project_id": 1,
    "is_approved": true,
    "project": { "..." },
    "members": [ "..." ]
  }
}
```

---

### Delete Team

```
DELETE /api/v1/teams/{id}
```

**Auth:** Required (Bearer Token)

**Response `200`:**
```json
{
  "success": true,
  "message": "Team deleted successfully"
}
```

**Response `404`:**
```json
{
  "success": false,
  "message": "Team not found"
}
```

---

### Join Team

```
POST /api/v1/teams/{id}/join
```

**Auth:** Required (Bearer Token)

Adds the authenticated student to the team as a `member`.

**Response `200`:**
```json
{
  "success": true,
  "message": "Successfully joined the team",
  "data": {
    "id": 1,
    "name": "Team Alpha",
    "project_id": 1,
    "is_approved": false,
    "project": { "..." },
    "members": [ "...updated members list..." ]
  }
}
```

**Response `400` (already member):**
```json
{
  "success": false,
  "message": "You are already a member of this team"
}
```

**Response `404` (team or student not found):**
```json
{
  "success": false,
  "message": "Team not found"
}
```
or
```json
{
  "success": false,
  "message": "Student profile not found"
}
```

---

## Error Responses

### Standard Error Format

All errors follow this consistent structure:

```json
{
  "success": false,
  "message": "Error description"
}
```

### Validation Error `422`

Laravel's default validation error format:

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
| `400` | Bad request (no skills survey, already a team member, team has no project) |
| `401` | Unauthorized (missing/invalid token, or invalid credentials at login) |
| `403` | Forbidden (insufficient role permissions, e.g., non-admin accessing admin routes) |
| `404` | Resource not found |
| `422` | Validation error |
| `500` | Internal server error |

---

## Quick Reference - All Endpoints

| # | Method | Endpoint | Auth | Role | Description |
|---|--------|----------|------|------|-------------|
| 1 | POST | `/register` | No | - | Register new user |
| 2 | POST | `/login` | No | - | Login and get token |
| 3 | POST | `/logout` | Yes | - | Logout (invalidate token) |
| 4 | GET | `/me` | Yes | - | Get current user with student profile |
| 5 | POST | `/user/skills` | Yes | - | Update student skills (replaces all) |
| 6 | GET | `/user/skills` | Yes | - | Get student skills |
| 7 | GET | `/majors` | No | - | List all majors |
| 8 | GET | `/majors/{id}` | No | - | Get single major with students |
| 9 | POST | `/majors` | Yes | admin | Create major |
| 10 | PUT | `/majors/{id}` | Yes | admin | Update major |
| 11 | DELETE | `/majors/{id}` | Yes | admin | Delete major |
| 12 | GET | `/skills` | No | - | List skills (filter: ?category=) |
| 13 | GET | `/skills/{id}` | No | - | Get skill with students & projects |
| 14 | POST | `/skills` | Yes | admin | Create skill |
| 15 | PUT | `/skills/{id}` | Yes | admin | Update skill |
| 16 | DELETE | `/skills/{id}` | Yes | admin | Delete skill |
| 17 | GET | `/projects` | No | - | List projects (paginated, filter: type_id, status, difficulty_level) |
| 18 | GET | `/projects/{id}` | No | - | Get project with full relations |
| 19 | POST | `/projects` | Yes | - | Create project |
| 20 | PUT | `/projects/{id}` | Yes | - | Update project |
| 21 | DELETE | `/projects/{id}` | Yes | - | Delete project |
| 22 | GET | `/recommendations` | Yes | - | Get personalized project recommendations |
| 23 | GET | `/projects/{id}/sandbox` | Yes | - | Get sandbox (milestones + risks + timeline) |
| 24 | GET | `/projects/{projectId}/estimate` | Yes | - | Estimate success probability (individual) |
| 25 | GET | `/teams` | Yes | - | List teams (paginated) |
| 26 | POST | `/teams` | Yes | - | Create team (auto-join as leader) |
| 27 | GET | `/teams/{id}` | Yes | - | Get team with members |
| 28 | PUT | `/teams/{id}` | Yes | - | Update team |
| 29 | DELETE | `/teams/{id}` | Yes | - | Delete team |
| 30 | POST | `/teams/{id}/join` | Yes | - | Join team as member |
| 31 | GET | `/teams/{teamId}/estimate` | Yes | - | Estimate success probability (team) |

**Total: 31 endpoints**

---

## Database Schema

### Tables Overview

```
users
├── id, name, email, password, role, email_verified_at, remember_token, timestamps
├── role: enum(student, advisor, admin) default: student
└── Relations: hasOne Student, hasMany Project (as supervisor)

students
├── id, user_id (FK→users), stud_num, first_name, last_name, gender, date_of_birth, major_id (FK→majors), timestamps
└── Relations: belongsTo User, belongsTo Major, belongsToMany Skill (via student_skills), belongsToMany Team (via team_members)

majors
├── id, name, code (unique), timestamps
└── Relations: hasMany Student

skills
├── id, name, category, timestamps
└── Relations: belongsToMany Student (via student_skills), belongsToMany Project (via project_skills)

project_types
├── id, name, timestamps
└── Relations: hasMany Project

projects
├── id, title, description, type_id (FK→project_types), difficulty_level (int 1-5), supervisor_id (FK→users), status (enum), timestamps
├── status: enum(available, in_progress, completed, cancelled) default: available
└── Relations: belongsTo User (supervisor), belongsTo ProjectType, belongsToMany Skill (via project_skills), hasMany Team, hasMany Milestone, hasMany Risk, hasMany SuccessEstimation

student_skills (pivot)
├── id, student_id (FK→students), skill_id (FK→skills), proficiency_level (int 1-5), interest_level (int 1-5), timestamps
└── unique(student_id, skill_id)

project_skills (pivot)
├── id, project_id (FK→projects), skill_id (FK→skills), weight (decimal 5,2), timestamps
└── Links projects to required skills with importance weight (0-1)

teams
├── id, name, project_id (FK→projects, cascade), is_approved (boolean default: false), timestamps
└── Relations: belongsTo Project, belongsToMany Student (via team_members), hasMany SuccessEstimation

team_members (pivot)
├── id, team_id (FK→teams), student_id (FK→students), role_in_team, timestamps
├── unique(team_id, student_id)
└── role_in_team: leader | member

milestones
├── id, project_id (FK→projects, cascade), title, description, estimated_days (int), order_sequence (int), timestamps
└── Ordered by order_sequence

risks
├── id, project_id (FK→projects, cascade), risk_description, impact_level (enum: Low, Medium, High), mitigation_plan, timestamps

success_estimations
├── id, team_id (FK→teams, nullable, cascade), student_id (FK→students, nullable, cascade), project_id (FK→projects, cascade), success_probability (decimal 5,2), calculated_at (timestamp), factors_log (json, nullable), timestamps
└── Records each estimation calculation for history

personal_access_tokens (Sanctum)
├── id, tokenable_type, tokenable_id, name, token (unique), abilities, last_used_at, expires_at, timestamps
```

### Entity Relationship Diagram

```
┌─────────┐     ┌──────────┐     ┌──────────┐
│  majors  │────<│ students │>────│   users  │
└─────────┘     └────┬─────┘     └────┬─────┘
                     │                 │
                     │                 │ (supervisor)
                     │                 ▼
               ┌─────┴──────┐   ┌─────────────┐     ┌──────────────┐
               │student_    │   │  projects    │>────│ project_types│
               │skills      │   └──────┬──────┘     └──────────────┘
               └─────┬──────┘          │
                     │                 │
                     ▼                 ▼
               ┌──────────┐     ┌─────────────┐
               │  skills   │>────│project_     │
               └──────────┘     │skills       │
                                └─────────────┘
                                ┌─────────────┐
                                │ milestones  │
                                │ risks       │
                                └─────────────┘
                                      │
┌──────────┐    ┌──────────────┐      │
│  teams   │>───│team_members  │      │
└────┬─────┘    └──────────────┘      │
     │                                │
     └────────────────────────────────┘
                (project_id)

┌────────────────────┐
│success_estimations │
│ - student_id (opt) │
│ - team_id (opt)    │
│ - project_id       │
└────────────────────┘
```

---

## Authentication Details

### Token-Based Auth (Laravel Sanctum)

All authenticated endpoints require the `Authorization` header:

```
Authorization: Bearer {token}
```

**Token lifecycle:**
- Tokens are issued on `POST /register` and `POST /login`
- Tokens do not expire by default (unless configured)
- `POST /logout` invalidates only the current token
- Each user can have multiple active tokens

**Middleware stack:**
- `auth:sanctum` — Validates Bearer token
- `role:admin` — Checks `users.role` column value (registered as middleware alias in `bootstrap/app.php`)

---

## Notes

1. **Pagination:** `GET /projects` and `GET /teams` return paginated results (10 per page). Use `?page=N` to navigate.
2. **Skill Weights:** Project skill weights are decimal values (0-1) representing importance. Higher weight = more important for matching.
3. **Auto-generation:** Sandbox milestones and risks are auto-generated on first access if the project has none. They are persisted to the database.
4. **Cascade Deletes:** Deleting a project cascades to its teams, milestones, risks, and success estimations. Deleting a user cascades to their student profile.
5. **Skill Replacement:** `POST /user/skills` deletes all existing student skills before inserting the new set.
6. **Project Skills Replacement:** `PUT /projects/{id}` with a `skills` array deletes all existing project skills before inserting the new set.
