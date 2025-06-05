<?php

namespace App\Controller;

use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\HttpFoundation\Response;
use Psr\Log\LoggerInterface;

class MobileActivityController extends AbstractController
{
    public function __construct(
        private Connection $connection,
        private LoggerInterface $logger
    ) {}

    #[Route('/api/mobile/camping/{id}/activities', name: 'api_mobile_camping_activities', methods: ['GET'])]
    public function getActivities(int $id): JsonResponse
    {
        try {
            $sql = "SELECT id, title, description, day, time, location, participants, type FROM activity WHERE camping_id = :id";
            $stmt = $this->connection->prepare($sql);
            $stmt->bindValue('id', $id);
            $result = $stmt->executeQuery();
            $activities = $result->fetchAllAssociative();

            return $this->json(['activities' => $activities]);
        } catch (\Exception $e) {
            $this->logger->error('Erreur lors de la récupération des activités: ' . $e->getMessage());
            return $this->json([
                'message' => 'Erreur lors de la récupération des activités',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
} 