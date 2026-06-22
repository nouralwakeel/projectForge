<?php

namespace App\Services\Assistant\Tools;

use App\Models\Student;

/**
 * Search students by name, student number, email or major. Useful to resolve a
 * student before asking about their work.
 */
class FindStudentTool extends Tool
{
    public function name(): string
    {
        return 'find_student';
    }

    public function description(): string
    {
        return 'البحث عن طلاب بالاسم أو الرقم الجامعي أو البريد الإلكتروني أو التخصص. يُرجع قائمة بالطلاب المطابقين.';
    }

    public function parameters(): array
    {
        return [
            'type' => 'object',
            'properties' => [
                'query' => [
                    'type' => 'string',
                    'description' => 'نص البحث: اسم أو رقم جامعي أو بريد أو تخصص.',
                ],
                'limit' => [
                    'type' => 'integer',
                    'description' => 'أقصى عدد نتائج (افتراضي 20).',
                ],
            ],
            'required' => ['query'],
        ];
    }

    public function handle(array $args): array
    {
        $term = trim((string) ($args['query'] ?? ''));

        if ($term === '') {
            return ['error' => 'نص البحث (query) مطلوب.'];
        }

        // Split into words so "first last" full-name queries match across columns
        // without relying on a DB-specific concatenation operator.
        $tokens = array_filter(preg_split('/\s+/', $term));

        $students = Student::query()
            ->with(['major', 'user'])
            ->where(function ($q) use ($term, $tokens) {
                $q->where('first_name', 'like', "%{$term}%")
                    ->orWhere('last_name', 'like', "%{$term}%")
                    ->orWhere('stud_num', 'like', "%{$term}%")
                    ->orWhereHas('user', fn ($u) => $u->where('email', 'like', "%{$term}%"))
                    ->orWhereHas('major', fn ($m) => $m->where('name', 'like', "%{$term}%"));

                // Every word must appear in either first or last name (full name match).
                if (count($tokens) > 1) {
                    $q->orWhere(function ($sub) use ($tokens) {
                        foreach ($tokens as $token) {
                            $sub->where(function ($inner) use ($token) {
                                $inner->where('first_name', 'like', "%{$token}%")
                                    ->orWhere('last_name', 'like', "%{$token}%");
                            });
                        }
                    });
                }
            })
            ->limit($this->limit($args))
            ->get();

        return [
            'count' => $students->count(),
            'students' => $students->map(fn ($s) => $this->formatStudentSummary($s) + [
                'email' => $s->user?->email,
            ])->all(),
        ];
    }
}
