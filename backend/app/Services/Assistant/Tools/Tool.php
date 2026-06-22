<?php

namespace App\Services\Assistant\Tools;

use App\Models\Project;
use App\Models\Student;

/**
 * Base class with shared formatting/normalization helpers used by the tools.
 * Keeps the output shape consistent across the assistant and the MCP server.
 */
abstract class Tool implements ToolInterface
{
    /** Clamp a requested limit into a sane range. */
    protected function limit(array $args, int $default = 20, int $max = 50): int
    {
        $limit = (int) ($args['limit'] ?? $default);

        return max(1, min($limit, $max));
    }

    /** Compact summary of a project for list views. */
    protected function formatProjectSummary(Project $project): array
    {
        return [
            'id' => $project->id,
            'title' => $project->title,
            'status' => $project->status,
            'difficulty_level' => $project->difficulty_level,
            'type' => $project->type?->name,
            'supervisor' => $project->supervisor?->name,
            'teams_count' => $project->teams_count ?? $project->teams()->count(),
        ];
    }

    /** Compact summary of a student. */
    protected function formatStudentSummary(Student $student): array
    {
        return [
            'id' => $student->id,
            'stud_num' => $student->stud_num,
            'name' => trim($student->first_name.' '.$student->last_name),
            'major' => $student->major?->name,
        ];
    }

    /**
     * Normalize Arabic/Latin text for fuzzy comparison: unify alef/hamza/ya/ta-marbuta,
     * strip diacritics (tashkeel) and tatweel, lowercase and collapse whitespace.
     */
    protected function normalize(string $text): string
    {
        $text = mb_strtolower(trim($text));

        // Remove Arabic diacritics (tashkeel) and tatweel.
        $text = preg_replace('/[\x{0617}-\x{061A}\x{064B}-\x{0652}\x{0640}]/u', '', $text);

        // Unify common Arabic letter variants.
        $map = [
            'أ' => 'ا', 'إ' => 'ا', 'آ' => 'ا',
            'ى' => 'ي', 'ئ' => 'ي',
            'ؤ' => 'و',
            'ة' => 'ه',
        ];
        $text = strtr($text, $map);

        // Collapse any run of non-letter/non-digit characters to a single space.
        $text = preg_replace('/[^\p{L}\p{N}]+/u', ' ', $text);

        return trim($text);
    }
}
