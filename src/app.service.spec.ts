import type { TestingModule } from "@nestjs/testing";
import { Test } from "@nestjs/testing";
import { AppService } from "./app.service";

describe("AppService", () => {
	let appService: AppService;

	beforeEach(async () => {
		const module: TestingModule = await Test.createTestingModule({
			providers: [
				{
					provide: AppService,
					useValue: {
						getHello: jest.fn(),
					},
				},
			],
		}).compile();

		appService = module.get<AppService>(AppService);
	});

	it("should be defined", () => {
		expect(appService).toBeDefined();
	});
});
